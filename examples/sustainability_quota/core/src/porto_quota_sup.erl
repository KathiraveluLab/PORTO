-module(porto_quota_sup).
-behaviour(supervisor).

-export([start_link/0, start_quota_check/3]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% Spawns a quota compliance actor for a participant.
start_quota_check(ParticipantId, Usage, Quota) ->
    supervisor:start_child(?SERVER, [ParticipantId, Usage, Quota]).

init([]) ->
    SupFlags = #{strategy  => simple_one_for_one,
                 intensity => 10,
                 period    => 5},
    ChildSpecs = [
        #{id       => porto_quota_actor,
          start    => {porto_quota_actor, start_link, []},
          restart  => temporary,
          shutdown => 2000,
          type     => worker,
          modules  => [porto_quota_actor]}
    ],
    {ok, {SupFlags, ChildSpecs}}.
