-module(porto_core_app).
-behaviour(application).

-export([start/2, stop/1, track_resource/1]).

%% @doc Dynamically spawns a new managed resource actor under the simple_one_for_one tree
track_resource(ResourceId) ->
    porto_resource_sup:start_resource(ResourceId).

start(_StartType, _StartArgs) ->
    %% Establish core memory structure for disaster recovery persistence.
    mnesia:create_schema([node()]),
    application:start(mnesia),
    io:format("Mnesia Database Sub-Layer Intialized~n"),
    
    %% Create persistence table replicating state histories
    mnesia:create_table(porto_state, 
        [{attributes, [id, history]}, 
         {disc_copies, [node()]}]),
         
    porto_core_sup:start_link().

stop(_State) ->
    ok.
