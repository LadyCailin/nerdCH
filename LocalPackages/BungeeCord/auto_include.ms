proc _writeUTF(@ba, @str) {
	@len = length(@str)
	if (@len > 200) {
		die('String too long')
	}
	ba_put_byte(@ba, 0)
	ba_put_byte(@ba, @len)
	ba_put_bytes(@ba, string_get_bytes(@str, 'ascii'))
}

proc _changeserver(@player, @server) {
	@ba = byte_array()
	_writeUTF(@ba, 'Connect')
	_writeUTF(@ba, @server)

	@servers = array('creative', 'pve', 'minigames', 'lobby')
	if (array_contains(@servers, to_lower(@server)) && to_lower(@server) != import('sharedata.source'), 
		unbind('bc-'.@player)
		bind('player_quit', array(priority: 'normal', id: 'bc-'.@player), array(player: @player), @event, @server,
			modify_event('message', color(yellow). @event['player'] . ' has switched to ' . @server)
			unbind()
		)
	)
	send_plugin_message(@player, 'BungeeCord', @ba)
}

proc _sendPluginMessage(@player, @channel, @messages) {
	if (@player != '~console') {
		@ba = byte_array()
		foreach (@messages, @message,
			_writeUTF(@ba, @message)
		)
		send_plugin_message(@player, @channel, @ba)
	}
}

@mcb_tab_completer = closure(@alias, @sender, @args){
    @res = array();
    foreach (@player in all_players()) {
    	if (@player == @sender) {
    		continue();
    	}
        if (string_position(@player, @args[-1]) == 0) {
            @res[] = @player;
        }
    }
    return(@res);
};

register_command('kick', array('tabcompleter':  @mcb_tab_completer));
register_command('ban', array('tabcompleter':  @mcb_tab_completer));
register_command('lookup', array('tabcompleter':  @mcb_tab_completer));
register_command('addnote', array('tabcompleter':  @mcb_tab_completer));
