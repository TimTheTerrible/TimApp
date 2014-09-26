#!/usr/bin/perl

use strict;

package TimApp;

use TimUtil;
use TimDB;
use TimObj;

our @ISA = qw(TimObj);

# App Debugging

# Unused place-holders...
use constant DEBUG_APP1	=> 0x0000100;
use constant DEBUG_APP2	=> 0x0000200;
use constant DEBUG_APP3	=> 0x0000400;
use constant DEBUG_APP4	=> 0x0000800;

my %DebugModes = (
);

# App Error Messages

my %ErrorMessages = (
);

# App Parameters

my %ParamDefs = (
);

#
# Class Definition
#

# TimApp::new
# Creates a new instance of the TimApp object.
#
# Inputs: $record - a hashref pointing to the object's starting values
# Outputs: none
# Returns: TimApp object
#
sub TimApp::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = TimObj->new($record);

    if ( ref($self) ) {
        bless($self, $class);
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create TimApp!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, "TimApp")?"SUCCESS":"FAILURE"));

    return $self;
}

# TimApp::init
# initializes the instance
#
# Inputs: $options - a hashref pointing to the program options
# Outputs: none
# Returns: E_NO_ERROR on successful completion, otherwise returns the error
#          code from the failed sub-function
#
sub TimApp::init
{
    my $self = shift;
    my ($params) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    unless ( $self->{initialized} ) {

        # Call the inherited init()...
        if ( ($returnval = $self->SUPER::init($self)) == E_NO_ERROR ) {

            # Parse command line arguments...
            my $options = {};
            parse_args($options);
            $self->{options} = $options;
            $self->{params} = TimUtil::enum_params();

            # Read the config file...
            if ( ($returnval = $self->read_config()) == E_NO_ERROR ) {

                # Set up the database connection...
                $self->{db} = TimDB->new($self->{DSN});

                debugprint(DEBUG_TRACE, "Initialization completed successfully");

            }
            else {
                debugprint(DEBUG_ERROR, "Failed to read configuration");
            }
        }
        else {
            debugprint(DEBUG_ERROR, "TimApp->init() failed!");
        }
    }
    else {
        debugprint(DEBUG_ERROR, "Already initialized!");
        # TODO: you know the drill...
        # $returnval = E_YOU_FUCKED_UP;
    }

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

# TimApp::run
# Run the main program loop. This is just a placeholder. This function must
# be overloaded in order for the app to do anything useful.
#
# Inputs: none
# Outputs: none
# Returns: E_NO_ERROR on successful completion, otherwise returns the error
#          code from the failed sub-function
#
sub TimApp::run
{
    my $self = shift;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    # Don't call me, call my children...
    $self->abstract("TimApp::run");

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

# TimApp::read_config
# Read the configuration file
#
# Inputs: none
# Outputs: none
# Returns: E_NO_ERROR on successful completion, otherwise returns the error
#          code from the failed sub-function
#
sub TimApp::read_config
{
    my $self = shift;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    # Don't call me, call my children...
    $returnval = $self->abstract("TimApp::read_config");

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

# TimApp::get_property
# Retreive a stored property, or return the supplied default.
#
# Inputs:  $class - the config class within which the property is valid
#          $property - the name of the property to get
#          $default - the default value to return if no stored value is found
# Outputs: none
# Returns: Either the stored value for $property, or the supplied default
#
sub TimApp::get_property
{
    my $self = shift;
    my ($class,$property,$default) = @_;

    my $result;

    # Order of precedence: $self, database, default
    if ( exists($self->{$property}) ) {
        $result = $self->{$property};
    }
    else {

        my $value;
        my $query = sprintf("SELECT value FROM settings WHERE class='%s' AND property='%s'", $class, $property);
        my $returnval = $self->{db}->get_str(\$value, $query);

        debugprint(DEBUG_TRACE, "query = '%s'", $query);
        debugprint(DEBUG_TRACE, "returnval = %s '%s'", error_message($returnval), $returnval);
        debugprint(DEBUG_TRACE, "value = '%s'", $value);

        # Did we get anything back?
        if ( $returnval == E_DB_NO_ERROR ) {
            $result = $value;
        }
        elsif ( $returnval == E_DB_NO_ROWS ) {
            # Create the class...
            $self->set_property($class,$property,$default);
            $result = $default;
        }
        else {
            debugprint(DEBUG_ERROR, "Query failed: '%s'", $query);
        }
    }

    debugprint(DEBUG_TRACE, "Returning '%s' for '%s::%s'", $result, $class, $property);

    return $result;
}

# TimApp::set_property
# Store a property for later retreival
#
# Inputs:  $class - the config class within which the property is valid
#          $property - the name of the property to set
#          $value - the property value to store
# Outputs: none
# Returns: none
#
sub TimApp::set_property
{
    my $self = shift;
    my ($class,$property,$value) = @_;

    # Create the class...
    my $query = sprintf("INSERT IGNORE INTO settings SET class='%s',property='%s',value='%s'",
        $class, $property, $value);

    debugprint(DEBUG_TRACE, "query='%s'", $query);

    $self->{db}->dbexec($query);
}

#
# Module Initialization
#

register_debug_modes(\%DebugModes);
register_error_messages(\%ErrorMessages);
register_params(\%ParamDefs);

# Done!

return SUCCESS;

