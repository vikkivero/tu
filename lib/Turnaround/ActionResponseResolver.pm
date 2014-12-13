package Turnaround::ActionResponseResolver;

use strict;
use warnings;

use Encode ();

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub resolve {
    my $self = shift;
    my ($res) = @_;

    return unless defined $res;

    unless (ref $res) {
        $res = Encode::encode('UTF-8', $res) if Encode::is_utf8($res);
        return [200, ['Content-Type' => 'text/html'], [$res]];
    }

    return $res if ref $res eq 'ARRAY';

    return $res if ref $res eq 'CODE';

    return $res->finalize if $res->isa('Turnaround::Response');

    return;
}

1;
