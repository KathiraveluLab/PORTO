-module(porto_core_app).
-behaviour(application).

-export([start/2, stop/1, track_resource/1]).

%% @doc Dynamically spawns a new managed resource actor under the simple_one_for_one tree
track_resource(ResourceId) ->
    porto_resource_sup:start_resource(ResourceId).

start(_StartType, _StartArgs) ->
    porto_core_sup:start_link().

stop(_State) ->
    ok.
