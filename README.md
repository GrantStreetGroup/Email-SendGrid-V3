# NAME

Email::SendGrid::V3 - Class for building a message to be sent through the SendGrid v3 Web API

# VERSION

version v0.900.1

# SYNOPSIS

    use Email::SendGrid::V3;

    my $sg = Email::SendGrid::V3->new(api_key => 'XYZ123');

    my $result = $sg->from('nobody@example.com')
                    ->subject('A test message for you')
                    ->add_content('text/plain', 'This is a test message sent with SendGrid')
                    ->add_envelope( to => [ 'nobody@example.com' ] )
                    ->send;

    print $result->{success} ? "It worked" : "It failed: " . $result->{reason};

# DESCRIPTION

This module allows for easy integration with the SendGrid email distribution
service and its v3 Web API.  All instance methods are chainable.

For the full details of the SendGrid v3 API, see [https://sendgrid.com/docs/API\_Reference/api\_v3.html](https://sendgrid.com/docs/API_Reference/api_v3.html)

# CLASS METHODS

## Creation

### new(%args)

Creates a new Email::SendGrid object.  Optional param: 'api\_key'

# INSTANCE METHODS

## Sending / Validating

### send(%args)

Sends the API request and returns a result hashref with these keys:

- `success` - Boolean indicating whether the operation returned a 2XX status code
- `status` - The HTTP status code of the response
- `reason` - The response phrase returned by the server
- `content` - The body of the response, including a detailed error message, if any.

### validate(%args)

Temporarily sets the 'sandbox\_mode' flag to true, and submits the API request
to SendGrid.  Returns the same hashref format as send().  If the 'success' key
is true, the API request is valid.

## Personalizations / Envelopes

### $self->add\_envelope(%args);

Once you've defined the general message parameters (by setting from, content, etc)
You must add at least one envelope.  Each envelope represents one personalized copy
of a message, and who should receive it.  Some parameters can only be set at the message
level, some only at the envelope level, and some at both (the envelop-level settings will
override the message-level settings).

You must specify at least the 'to' argument, which is an array of recipient emails.  This
can be a plain array of addresses, or an array of hashes with 'email' and 'name' keys.

The 'cc' and 'bcc' arguments are optional, but follow the same format of the 'to' argument.

In addition to specifying the envelope recipients via to/cc/bcc, you can also override the
message 'subject', 'send\_at', 'headers' hash, 'substitutions' hash, and 'custom\_args' hash.
See the message-level methods for more details on those parameters.

### $self->clear\_envelopes();

Clears all of the currently defined envelopes from this message.

## Messages

### $self->from($email, $name);

Sets the name/email address of the sender.
Email is required, name is optional.

### $self->subject($subject);

Sets the subject of the message.
Required, but can be overridden at the message personalization level.

### $self->reply\_to($email, $name);

Sets the target that will be used if the recipient wants to reply to this message.
Email is required, name is optional.

### $self->clear\_content();

Clears out all of the message body parts.

### $self->add\_content($type, $value);

Adds a message body part. Both type and value are required.
$type should be something like "text/plain" or "text/html".

### $self->clear\_attachments();

Removes all attachments from this message.

### $self->add\_attachment($filename, $content, %args);

Adds a new attachment to this message.  $filename specifies the file name the recipient will see.
$content should be the Base64-encoded data of the file. Optional arguments are 'type' (the mime type
of the file, such as "image/jpeg"), 'disposition' must be "inline" or "attachment", and 'content\_id'
which is used to identify embedded inline attachments.

### $self->template\_id($template\_id);

Specifies the template you'd like to use for this message.  Templates are managed via the
SendGrid application website.  If the template includes a subject or body, those do not need
to be specified via this api.

### $self->clear\_sections();

Clears all substitution sections defined in this message.

### $self->remove\_section($key);

Removes one substitution section defined in this message.

### $self->set\_section($key, $value);

Sets one new substitution section for this message.  Each occurrence of $key
in each body part will be replaced with $value prior to personalization
substitutions (if any).

### $self->set\_sections(%sections);

Sets all substitution sections for this message at once.  For each key/val pair,
occurrences of the key in the message body will be replaced by the value prior to
personalization substitutions (if any).

### $self->clear\_headers();

Clears all custom headers defined for this message.

### $self->set\_headers(%headers);

Sets all custom SMTP headers for this message at once. These must be properly encoded
if they contain unicode characters. Must not be one of the reserved headers.

These can be overridden at the message personalization level.

### $self->clear\_categories();

Clears out all categories defined for this message.

### $self->set\_categories(@categories);

Sets the list of categories for this message.  The list of categories must be
unique and contain no more than 10 items.

### $self->add\_category($name);

Adds a new category for this message.  The list of categories must be
unique and contain no more than 10 items.

### $self->clear\_custom\_args();

Clears out all custom arguments defined for this message.

### $self->set\_custom\_args(%args);

Sets all custom arguments defined for this message.
These can be overridden at the message personalization level.
The total size of custom arguments cannot exceed 10,000 bytes.

### $self->send\_at($timestamp);

A unix timestamp (seconds since 1970) specifying when to deliver this message.
Cannot be more than 72 hours in the future.

This can be overridden at the message personalization level.

### $self->batch\_id($batch\_id);

Identifies a batch to include this message in.  This batch ID can later be used
to pause or cancel the delivery of a batch (if a future delivery time was set)

### $self->unsubscribe\_group($group\_id, @display\_groups);

If you've set up multiple unsubscribe groups in the SendGrid web application, this method
allows you to specify which group this message belongs to.  If this is set and the user
unsubscribes from this message, they will only be added to the suppression list for that
single group.  If not set, they will be added to the global unsubscribe list.

@display\_groups is optional. If specified, when the user clicks "unsubscribe" they will be
shown a list of these groups and allowed to choose which ones he/she would like to unsubscribe
from.

### $self->ip\_pool\_name($pool\_name);

The IP Pool that you would like to send this email from.

### $self->click\_tracking($enable, %args);

Whether to enable click-tracking for this message.  If enabled, any URLs in the body of this
message will be rewritten to proxy through SendGrid for tracking purposes.  This setting will
overwrite the account-level setting if any.  One optional argument is accepted: 'enable\_text'
which controls whether the link-rewriting is also performed for plaintext emails (the rewritten
URL will be visible to the recipient)

### $self->open\_tracking($enable, %args);

Whether to enable open-tracking for this message.  If enabled, a single transparent pixel image
is added to the HTML body of this message and used to determine if and when the recipient opens
the message.  This setting will overwrite the account-level setting if any.  One optional argument
is accepted: 'substitution\_tag' which identifies a token in the message body that should be replaced
with the tracking pixel.

### $self->subscription\_tracking($enable, %args);

Whether to enable a sendgrid-powered unsubscribe link in the footer of the email.  You may pass
optional arguments 'text' and 'html' to control the verbiage of the unsubscribe link used, OR
'substitution\_tag' which is a token that will be replaced with the unsubscribe URL.
This setting will overwrite the account-level setting if any.

### $self->ganalytics($enable, %args);

Whether to enable google analytics tracking for this message.  Optional arguments
include 'utm\_source', 'utm\_medium', 'utm\_term', 'utm\_content', and 'utm\_campaign'.
This setting will overwrite the account-level setting if any.

### $self->bcc($enable, %args);

Whether to BCC a monitoring account when sending this message.  Optional arguments
include 'email' for the address that will receive the BCC if one is not configured
at the account level.  This setting will overwrite the account-level setting if any.

### $self->bypass\_list\_management($enable);

Whether to bypass the built-in suppression SendGrid provides, such as unsubscribed
recipients, those that have bounced, or marked the emails as spam.
This setting will overwrite the account-level setting if any.

### $self->footer($enable, %args);

Whether to add a footer to the outgoing message. Optional arguments include 'html' and
'text' to specify the footers that will be used for each message body type.
This setting will overwrite the account-level setting if any.

### $self->sandbox\_mode($enable);

Whether to enable sandbox mode.  When enabled, SendGrid will validate the contents of this
API request for correctness, but will not actually send the message.

### $self->spam\_check($enable, %args);

Whether to perform a spam check on this message prior to sending.  If the message fails the
spam check, it will be dropped and not sent.  Optional parameters include 'threshold' - an
integer score value from 1-10 (default 5) over which a message will be classified as spam,
and 'post\_to\_url' - a SendGrid inbound message parsing URL that will be used to post back
notifications of messages identified as spam and dropped.  These settings will overwrite
the account-level settings if any.

# AUTHOR

Grant Street Group <developers@grantstreet.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 - 2020 by Grant Street Group.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
