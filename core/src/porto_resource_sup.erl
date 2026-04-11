-module(porto_resource_sup).
-behaviour(supervisor).

-export([start_link/0, start_resource/1]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_resource(ResourceId) ->
    supervisor:start_child(?SERVER, [ResourceId]).

init([]) ->
    SupFlags = #{strategy => simple_one_for_one,
                 intensity => 10,
                 period => 5},
    ChildSpecs = [
        #{id => porto_resource_actor,
          start => {porto_resource_actor, start_link, []},
          restart => temporary,
          shutdown => 2000,
          type => worker,
          modules => [porto_resource_actor]}
    ],
    {ok, {SupFlags, ChildSpecs}}.
