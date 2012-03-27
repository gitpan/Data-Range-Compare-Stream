package Data::Range::Compare::Stream::Iterator::File;

use strict;
use warnings;
use IO::File;
use base qw(Data::Range::Compare::Stream::Iterator::Base);
use Data::Range::Compare::Stream;


use constant NEW_FROM=>'Data::Range::Compare::Stream';


sub new {
  my ($class,%args)=@_;
  my $has_next;
  my $self=$class->SUPER::new(%args);

  if(defined($args{filename})) {
    my $fh=IO::File->new($args{filename});
    if($fh) {
       $self->{fh}=$fh;
       my $line=$fh->getline;
       $self->{next_line}=$line;
       $has_next=defined($line);
    } else {
      $self->{msg}="Error could not open $args{filename} error was: $!";
    }

  } else {
    $self->{msg}="filename=>undef";
  }

  $self->{has_next}=$has_next;
  return $self;
}

sub in_error {
  my ($self)=@_;
  return 1 if defined($self->{msg});
  return 0;
}

sub get_error { $_[0]->{msg} }

sub to_string {
  my ($self)=@_;
  return $self->{filename};
}

sub get_next {
  my ($self)=@_;
  return undef unless $self->has_next;

  my $line=$self->{next_line};
  $self->{next_line}=$self->{fh}->getline;
  $self->{has_next}=defined($self->{next_line});

  return $self->NEW_FROM->new(@{$self->parse_line($line)});
}

sub parse_line {
  my ($self,$line)=@_;
  chomp $line;
  [split /\s+/,$line];
}

1;
