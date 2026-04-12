-module(porto_quota_actor).
-behaviour(gen_server).

-export([start_link/3, verify/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link(ParticipantId, Usage, Quota) ->
    gen_server:start_link(?MODULE, [ParticipantId, Usage, Quota], []).

verify(Pid) ->
    gen_server:call(Pid, verify, infinity).

init([ParticipantId, Usage, Quota]) ->
    pg:join(porto_cluster, porto_quota_checks, self()),
    io:format("Quota Actor started for participant ~p~n", [ParticipantId]),
    {ok, #{participant_id => ParticipantId,
           usage          => Usage,
           quota          => Quota}}.

handle_call(verify, _From, State = #{participant_id := PId,
                                     usage          := Usage,
                                     quota          := Quota}) ->
    %% Hard-error policy: constraint violation (usage > quota) causes leo run to
    %% exit non-zero, {ok, _} will not match, and this actor crashes cleanly.
    {ok, Result} = porto_leo_bridge:verify_quota(PId, Usage, Quota),
    io:format("Quota verified for ~p: ~p~n", [PId, Result]),

    %% Persist compliance record to Mnesia for auditability.
    mnesia:activity(transaction, fun() ->
        mnesia:write({porto_state, PId, {quota_compliant, Usage, Quota}})
    end),

    {reply, {ok, Result}, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
