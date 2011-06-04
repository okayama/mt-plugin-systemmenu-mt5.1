package MT::Plugin::SystemMenu;
use strict;
use MT;
use MT::Plugin;
use base qw( MT::Plugin );

use MT::Util qw( encode_html );

our $VERSION = '1.0';

my $plugin = MT::Plugin::SystemMenu->new( {
    id => 'SystemMenu',
    key => 'systemmenu',
    description => '<MT_TRANS phrase=\'_PLUGIN_DESCRIPTION\'>',
    name => 'SystemMenu',
    author_name => 'okayama',
    author_link => 'http://weeeblog.net/',
    version => $VERSION,
    settings => new MT::PluginSettings( [
        [ 'show_dashboard', { Default => 1 } ],
        [ 'show_list_website', { Default => 1 } ],
        [ 'show_list_user', { Default => 1 } ],
        [ 'show_list_templates', { Default => 1 } ],
        [ 'show_cfg_plugins', { Default => 1 } ],
        [ 'show_view_log', { Default => 1 } ],
    ] ),
    l10n_class => 'MT::SystemMenu::L10N',
    system_config_template => 'systemmenu_config.tmpl',
} );
MT->add_plugin( $plugin );

sub init_registry {
    my $plugin = shift;
    $plugin->registry( {
        callbacks => {
            'MT::App::CMS::template_source.scope_selector'
                => \&_cb_ts_header,
        },
   } );
}

sub _cb_ts_header {
    my ( $cb, $app, $tmpl ) = @_;
    my $transform = 0;
    my $list;
    if ( $plugin->get_config_value( 'show_list_website' ) ) {
        if ( $app->user->can_do( 'create_website' ) ) {
            $list .= '<li><a href="<$mt:var name="mt_url">?__mode=list&amp;_type=website&amp;blog_id=0&amp;return_args=<$mt:var name="return_args" escape="url"$>"><__trans phrase="Websites"></a></li>' . "\n";
        }
    }
    if ( $plugin->get_config_value( 'show_list_user' ) ) {
        if ( $app->user->is_superuser ) {
            $list .= '<li><a href="<$mt:var name="mt_url">?__mode=list&amp;_type=author&amp;blog_id=0&amp;return_args=<$mt:var name="return_args" escape="url"$>"><__trans phrase="Users"></a></li>' . "\n";
        }
    }
    if ( $plugin->get_config_value( 'show_list_templates' ) ) {
        if ( $app->user->can_do( 'edit_templates' ) ) {
            $list .= '<li><a href="<$mt:var name="mt_url">?__mode=list_template&amp;blog_id=0&amp;return_args=<$mt:var name="return_args" escape="url"$>"><__trans phrase="Templates"></a></li>' . "\n";
        }
    }
    if ( $plugin->get_config_value( 'show_cfg_plugins' ) ) {
        if ( $app->user->can_manage_plugins ) {
            $list .= '<li><a href="<$mt:var name="mt_url">?__mode=cfg_plugins&amp;blog_id=0&amp;return_args=<$mt:var name="return_args" escape="url"$>"><__trans phrase="Plugins"></a></li>' . "\n";
        }
    }
    if ( $plugin->get_config_value( 'show_view_log' ) ) {
        if ( $app->user->can_view_log ) {
            $list .= '<li><a href="<$mt:var name="mt_url">?__mode=list&amp;_type=log&amp;blog_id=0&amp;return_args=<$mt:var name="return_args" escape="url"$>"><__trans phrase="System Activity Feed"></a></li>' . "\n";
        }
    }
    if ( $list ) {
        my $insert = <<'CSS';
<style type="text/css">
    #selector-nav #system-menu-list {
        border-top:1px solid #DBDCDC;
    }
    #selector-nav #system-menu-list a:hover {
        background-color: #7F8081;
    }
</style>
CSS
        $insert .= '<mt:unless name="scope_type" eq="system">' . "\n";
        $insert .= '<ul id="system-menu-list">' . "\n";
        $insert .= '   <li><span class="sticky-label scope-level system"><__trans phrase="System Overview"></span>' . "\n";
        $insert .= '       <ul>' . "\n";
        if ( $plugin->get_config_value( 'show_dashboard' ) ) {
            $insert .= '           <li><a href="<$mt:var name="mt_url">?blog_id=0&amp;return_args=<$mt:var name="return_args" escape="url"$>"><__trans phrase="Dashboard"></a></li>' . "\n";
        }
        $insert .= $list;
        $insert .= '       </ul>' . "\n";
        $insert .= '   </li>' . "\n";
        $insert .= '</ul>' . "\n";
        $insert .= '</mt:unless>' . "\n";
        my $search = quotemeta( '<mt:if name="fav_website_loop">' );
        if ( $$tmpl =~ s!($search)!$insert$1!s ) {
            $$tmpl =~ s!(<mt:unless name="scope_type" eq="system">).*?(</mt:unless>)!!s;
        }
    }
}

1;