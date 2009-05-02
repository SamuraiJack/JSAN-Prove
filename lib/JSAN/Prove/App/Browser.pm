package JSAN::Prove::App::Browser;

use Moose;

use Proc::Background;


#================================================================================================================================================================================================================================================
has 'proc' => (
	is => 'rw'
);



#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub get_exe_path {
	my ($self, $url) = @_;
	
	die "Abstract method get_exe_path was called";
}


#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub start {
    my ($self, $url) = @_;
    
    $self->proc(Proc::Background->new($self->get_exe_path($url)));
}

 
#================================================================================================================================================================================================================================================
#================================================================================================================================================================================================================================================
sub stop {
    my $self = shift;
    
    $self->proc->die() if $self->proc;
}

1;