uuid = require('uuid')
test_run = require('test_run').new()

box.schema.user.grant('guest', 'replication')

-- gh-2991 - Tarantool asserts on box.cfg.replication update if one of
-- servers is dead
replication_timeout = box.cfg.replication_timeout
replication_connect_timeout = box.cfg.replication_connect_timeout
box.cfg{replication_timeout=0.05, replication_connect_timeout=0.05, replication={}}
box.cfg{replication = {'127.0.0.1:12345', box.cfg.listen}}

-- gh-3606 - Tarantool crashes if box.cfg.replication is updated concurrently
fiber = require('fiber')
c = fiber.channel(2)
f = function() fiber.create(function() pcall(box.cfg, {replication = {12345}}) c:put(true) end) end
f()
f()
c:get()
c:get()

box.cfg{replication_timeout = replication_timeout, replication_connect_timeout = replication_connect_timeout}

-- gh-3111 - Allow to rebootstrap a replica from a read-only master
replica_uuid = uuid.new()
test_run:cmd('create server test with rpl_master=default, script="replication/replica_uuid.lua"')
test_run:cmd(string.format('start server test with args="%s"', replica_uuid))
test_run:cmd('stop server test')
test_run:cmd('cleanup server test')
box.cfg{read_only = true}
test_run:cmd(string.format('start server test with args="%s"', replica_uuid))
test_run:cmd('stop server test')
test_run:cmd('cleanup server test')
box.cfg{read_only = false}
test_run:cmd('delete server test')
test_run:cleanup_cluster()

-- gh-3160 - Send heartbeats if there are changes from a remote master only
SERVERS = { 'autobootstrap1', 'autobootstrap2', 'autobootstrap3' }

-- Deploy a cluster.
test_run:create_cluster(SERVERS, "replication", {args="0.1"})
test_run:wait_fullmesh(SERVERS)
test_run:cmd("switch autobootstrap1")
test_run = require('test_run').new()
box.cfg{replication_timeout = 0.01, replication_connect_timeout=0.01}
test_run:cmd("switch autobootstrap2")
test_run = require('test_run').new()
box.cfg{replication_timeout = 0.01, replication_connect_timeout=0.01}
test_run:cmd("switch autobootstrap3")
test_run = require('test_run').new()
fiber=require('fiber')
box.cfg{replication_timeout = 0.01, replication_connect_timeout=0.01}
_ = box.schema.space.create('test_timeout'):create_index('pk')
test_run:cmd("setopt delimiter ';'")
function test_timeout()
    for i = 0, 99 do 
        box.space.test_timeout:replace({1})
        fiber.sleep(0.005)
        local rinfo = box.info.replication
        if rinfo[1].upstream and rinfo[1].upstream.status ~= 'follow' or
           rinfo[2].upstream and rinfo[2].upstream.status ~= 'follow' or
           rinfo[3].upstream and rinfo[3].upstream.status ~= 'follow' then
            return error('Replication broken')
        end
    end
    return true
end ;
test_run:cmd("setopt delimiter ''");
test_timeout()

-- gh-3247 - Sequence-generated value is not replicated in case
-- the request was sent via iproto.
test_run:cmd("switch autobootstrap1")
net_box = require('net.box')
_ = box.schema.space.create('space1')
_ = box.schema.sequence.create('seq')
_ = box.space.space1:create_index('primary', {sequence = true} )
_ = box.space.space1:create_index('secondary', {parts = {2, 'unsigned'}})
box.schema.user.grant('guest', 'read,write', 'space', 'space1')
c = net_box.connect(box.cfg.listen)
c.space.space1:insert{box.NULL, "data"} -- fails, but bumps sequence value
c.space.space1:insert{box.NULL, 1, "data"}
box.space.space1:select{}
vclock = test_run:get_vclock("autobootstrap1")
_ = test_run:wait_vclock("autobootstrap2", vclock)
test_run:cmd("switch autobootstrap2")
box.space.space1:select{}
test_run:cmd("switch autobootstrap1")
box.space.space1:drop()

test_run:cmd("switch default")
test_run:drop_cluster(SERVERS)
test_run:cleanup_cluster()

-- gh-3642 - Check that socket file descriptor doesn't leak
-- when a replica is disconnected.
rlimit = require('rlimit')
lim = rlimit.limit()
rlimit.getrlimit(rlimit.RLIMIT_NOFILE, lim)
old_fno = lim.rlim_cur
lim.rlim_cur = 64
rlimit.setrlimit(rlimit.RLIMIT_NOFILE, lim)

test_run:cmd('create server sock with rpl_master=default, script="replication/replica.lua"')
test_run:cmd('start server sock')
test_run:cmd('switch sock')
test_run = require('test_run').new()
fiber = require('fiber')
test_run:cmd("setopt delimiter ';'")
for i = 1, 64 do
    local replication = box.cfg.replication
    box.cfg{replication = {}}
    box.cfg{replication = replication}
    while box.info.replication[1].upstream.status ~= 'follow' do
        fiber.sleep(0.001)
    end
end;
test_run:cmd("setopt delimiter ''");

box.info.replication[1].upstream.status

test_run:cmd('switch default')

lim.rlim_cur = old_fno
rlimit.setrlimit(rlimit.RLIMIT_NOFILE, lim)

test_run:cmd("stop server sock")
test_run:cmd("cleanup server sock")
test_run:cmd("delete server sock")
test_run:cleanup_cluster()

box.schema.user.revoke('guest', 'replication')

-- gh-3510 assertion failure in replica_on_applier_disconnect()
test_run:cmd('create server er_load1 with script="replication/er_load1.lua"')
test_run:cmd('create server er_load2 with script="replication/er_load2.lua"')
test_run:cmd('start server er_load1 with wait=False, wait_load=False')
-- instance er_load2 will fail with error ER_READONLY. this is ok.
-- We only test here that er_load1 doesn't assert.
test_run:cmd('start server er_load2 with wait=True, wait_load=True, crash_expected = True')
test_run:cmd('stop server er_load1')
-- er_load2 exits automatically.
test_run:cmd('cleanup server er_load1')
test_run:cmd('cleanup server er_load2')
test_run:cmd('delete server er_load1')
test_run:cmd('delete server er_load2')
test_run:cleanup_cluster()

--
-- Test case for gh-3637. Before the fix replica would exit with
-- an error. Now check that we don't hang and successfully connect.
--
fiber = require('fiber')
test_run:cmd("create server replica_auth with rpl_master=default, script='replication/replica_auth.lua'")
test_run:cmd("start server replica_auth with wait=False, wait_load=False, args='cluster:pass 0.05'")
-- Wait a bit to make sure replica waits till user is created.
fiber.sleep(0.1)
box.schema.user.create('cluster', {password='pass'})
box.schema.user.grant('cluster', 'replication')

while box.info.replication[2] == nil do fiber.sleep(0.01) end
vclock = test_run:get_vclock('default')
_ = test_run:wait_vclock('replica_auth', vclock)

test_run:cmd("stop server replica_auth")
test_run:cmd("cleanup server replica_auth")
test_run:cmd("delete server replica_auth")
test_run:cleanup_cluster()

box.schema.user.drop('cluster')

--
-- Test case for gh-3610. Before the fix replica would fail with the assertion
-- when trying to connect to the same master twice.
--
box.schema.user.grant('guest', 'replication')
test_run:cmd("create server replica with rpl_master=default, script='replication/replica.lua'")
test_run:cmd("start server replica")
test_run:cmd("switch replica")
replication = box.cfg.replication
box.cfg{replication = {replication, replication}}

-- Check the case when duplicate connection is detected in the background.
test_run:cmd("switch default")
listen = box.cfg.listen
box.cfg{listen = ''}

test_run:cmd("switch replica")
box.cfg{replication_connect_quorum = 0, replication_connect_timeout = 0.01}
box.cfg{replication = {replication, replication}}

test_run:cmd("switch default")
box.cfg{listen = listen}
while test_run:grep_log('replica', 'duplicate connection') == nil do fiber.sleep(0.01) end

test_run:cmd("stop server replica")
test_run:cmd("cleanup server replica")
test_run:cmd("delete server replica")
test_run:cleanup_cluster()
box.schema.user.revoke('guest', 'replication')
