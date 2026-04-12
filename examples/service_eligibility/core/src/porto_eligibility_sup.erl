-module(porto_eligibility_sup).
-behaviour(supervisor).

-export([start_link/0, start_eligibility_check/3]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% Spawns an eligibility check actor for an applicant.
start_eligibility_check(ApplicantId, Score, Threshold) ->
    supervisor:start_child(?SERVER, [ApplicantId, Score, Threshold]).

init([]) ->
    SupFlags = #{strategy  => simple_one_for_one,
                 intensity => 10,
                 period    => 5},
    ChildSpecs = [
        #{id       => porto_eligibility_actor,
          start    => {porto_eligibility_actor, start_link, []},
          restart  => temporary,
          shutdown => 2000,
          type     => worker,
          modules  => [porto_eligibility_actor]}
    ],
    {ok, {SupFlags, ChildSpecs}}.
