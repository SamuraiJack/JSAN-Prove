package JSAN::Prove::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

JSAN::Prove::Controller::Root - Root Controller for JSAN::Prove

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

use Data::Dump qw(dump);
use Path::Class;

use Moose;

has 'is_passed' => ( is => 'rw', default => 1 );

has 'browsers' => ( is => 'rw' );


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub index :Path {
	my ( $self, $c, @captures ) = @_;
}


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub prove :Local :Args(1) {
    my ( $self, $c, $browser ) = @_;
	
	$c->stash->{title} = $c->config->{title};
	$c->stash->{urls} = $c->config->{urls};
	$c->stash->{browser} = $browser;
	
	$c->stash->{template} = 'harness.tt';
}



#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub proven :Local :Args(2) {
    my ( $self, $c, $browser, $result ) = @_;
	
	$self->{is_passed} &&= $result eq 'pass' ? 1 : 0; 
	my $running = $self->stop_browser($browser);
	
	if ($running) {
		$c->response->body( $result );
	} else {
		exit($self->is_passed);
	}
}


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub inc :Local {
    my ( $self, $c, @captures ) = @_;
	$c->serve_static_file(file($c->config->{'JSAN_LIB'}, 'lib', @captures));
}


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub static :Local {
    my ( $self, $c, @captures ) = @_;
	$c->serve_static_file(file($c->config->{'JSAN_LIB'}, 'static', @captures));
}


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub local :Local {
    my ( $self, $c, @captures ) = @_;
	$c->serve_static_file(file('.', @captures));
}


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub start :Local {
    my ( $self, $c ) = @_;
    
	my $url = $c->get_self_url;
	
	$self->browsers({});
	
	foreach my $browser (@{$c->config->{browsers}}) {
		my $class_name = 'JSAN::Prove::App::Browser::' . $browser;
		eval "require $class_name";
		
		$self->browsers->{$browser} = $class_name->new();
		$self->browsers->{$browser}->start($url . "/prove/$browser");
	}
	
	$c->response->body('started');
}


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub stop_browser {
	my ($self, $browser) = @_;
	
	$self->browsers->{$browser}->stop();
	
	my $running = 0;
	foreach (values(%{$self->browsers})) {
		$running = 1 if $_->proc->alive;
	}
	
	return $running;
}


=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

SamuraiJack

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
