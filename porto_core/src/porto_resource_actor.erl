-module(porto_resource_actor).
-behaviour(gen_server).

-export([start_link/1, report_telemetry/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link(ResourceId) ->
    gen_server:start_link(?MODULE, [ResourceId], []).

report_telemetry(Pid, Metrics) ->
    gen_server:cast(Pid, {report, Metrics}).

init([ResourceId]) ->
    pg:join(porto_cluster, porto_resources, self()),
    io:format("Starting Resource Actor [~p] and joining global cluster group~n", [ResourceId]),
    {ok, #{id => ResourceId, state_history => []}}.

handle_cast({report, Metrics}, State = #{id := RId, state_history := History}) ->
    io:format("Actor ~p received telemetry: ~p~n", [RId, Metrics]),
    %% Accumulate telemetry until a ZK verification block is needed.
    %% Trigger Leo verification through the Bridge manually for POC:
    {ok, ProofResult} = porto_leo_bridge:verify_proof(Metrics),
    io:format("Zero-Knowledge Verification result for ~p: ~p~n", [RId, ProofResult]),
    {noreply, State#{state_history => [Metrics | History]}};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
