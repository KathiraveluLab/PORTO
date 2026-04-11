-module(porto_core_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [
        #{id => porto_pg_cluster,
          start => {pg, start_link, [porto_cluster]},
          restart => permanent,
          shutdown => 5000,
          type => worker,
          modules => [pg]},
        #{id => porto_leo_bridge,
          start => {porto_leo_bridge, start_link, []},
          restart => permanent,
          shutdown => 5000,
          type => worker,
          modules => [porto_leo_bridge]},
        #{id => porto_resource_sup,
          start => {porto_resource_sup, start_link, []},
          restart => permanent,
          shutdown => infinity,
          type => supervisor,
          modules => [porto_resource_sup]}
    ],
    {ok, {SupFlags, ChildSpecs}}.
