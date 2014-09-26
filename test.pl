#!/usr/bin/perl

use strict;

package TestApp;

use TimUtil;
use TimApp;

our @ISA = qw(TimApp);

sub TestApp::run
{
    my $self = shift;
    my ($options) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    printf("%s\n", $self->{config}->{message});

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

sub TestApp::init
{
    my $self = shift;
    my ($options) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    $returnval = $self->SUPER::init($options);

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

sub TestApp::read_config
{
    my $self = shift;
    my ($options) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    $self->{config} = {};

    $self->{config}->{message} = "Hello, World!";

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

package main;

use TimUtil;
use TimApp;
use TimObj;

parse_args();

my $app = TestApp->new();

my $returnval = E_NO_ERROR;

if ( UNIVERSAL::isa($app, "TimApp") ) {

    if ( ($returnval = $app->init()) == E_NO_ERROR ) {
        $returnval = $app->run();
    }
    else {
        debugprint(DEBUG_ERROR, "Application Initialization Failed");
    }
}
else {
    debugprint(DEBUG_ERROR, "Invalid Object");
    $returnval = E_INVALID_OBJECT;
}

exit $returnval;

