#
# Ermagerd individual players' chat or just everyone!
#

@ermagerd_players = associative_array()
export('ermagerd_players', @ermagerd_players)

# See if a player is ermagerd
proc _is_ermagerd() {
        @ermagerd_players = import('ermagerd_players')
        @ermagerd = array_index_exists(@ermagerd_players, '*')
                 || array_index_exists(@ermagerd_players, to_lower(player()));
        return(@ermagerd);
}

# Ermagerd!
proc _ermagerd2(@string) {
	# Note. (?i) will ignore case
	#       (?<!X) negative lookbehind
	#       (?!X) negative lookahead
        # Begin the transformations
        @string = reg_replace('oo?[rh]?', 'er', @string);
        @string = reg_replace('(?i)oo?[rh]?', 'ER', @string);
        @string = reg_replace('a', 'er', @string);
        @string = reg_replace('A', 'ER', @string);
        @string = reg_replace('(?<![a-zA-Z])ermg(?![a-zA-Z])', 'ermagerd', @string);
        @string = reg_replace('(?i)(?<![a-zA-Z])ermg(?![a-zA-Z])', 'ERMAGERD', @string);
        @string = reg_replace('my', 'ma', @string);
        @string = reg_replace('(?i)my', 'MA', @string);
        @string = reg_replace('[\\.,;]', '', @string); #Pfft, who needs punctuation
        return(@string);
}

# Filter chat
bind('player_chat', null, null, @event,
        if(!_is_ermagerd()) {
                die();
        }

        @string = @event['message'];
        @string = _ermagerd2(@string);
        modify_event('message', @string);
)

# Filter chat commands too! No Excape!
bind('player_command', null, null, @event,
        @cmd = @event['prefix']
        if((@cmd == '/me' || @cmd == '/s') && _is_ermagerd()) {
                @full_cmd = @event['command'];
                @parts    = split(' ', @full_cmd, 1);
                if(length(@parts) == 2) {
                        #console('Got command: ' . @cmd);
                        @cmd  = @parts[0];
                        @args = @parts[1];
                        modify_event('command', @cmd . ' ' . _ermagerd2(@args));
                }
        }
)

