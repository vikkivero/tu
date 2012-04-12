package MiddlewareLanguageDetectionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Middleware::LanguageDetection;

sub detect_from_session : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {'psgix.session' => {'lamework.language' => 'ru'}};

    $mw->call($env);

    is($env->{'lamework.language'}, 'ru');
}

sub detect_from_path : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is($env->{'lamework.language'}, 'ru');
}

sub modify_path : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '/ru/hello'};

    $mw->call($env);

    is($env->{PATH_INFO}, '/hello');
}

sub detect_from_headers : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '', HTTP_ACCEPT_LANGUAGE => 'ru'};

    $mw->call($env);

    is($env->{'lamework.language'}, 'ru');
}

sub set_default_language_when_unknown_detected : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {'psgix.session' => {'lamework.language' => 'es'}};

    $mw->call($env);

    is($env->{'lamework.language'}, 'en');
}

sub set_default_language_when_not_detected : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => ''};

    $mw->call($env);

    is($env->{'lamework.language'}, 'en');
}

sub save_to_session : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is($env->{'psgix.session'}->{'lamework.language'}, 'ru');
}

sub _build_middleware {
    my $self = shift;

    return Lamework::Middleware::LanguageDetection->new(
        app => sub { [200, [], ['OK']] },
        @_
    );
}

1;
