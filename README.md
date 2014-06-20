ultrasoap-ruby
==============

Ruby gem to interact with UltraDNS SOAP API.
This gem is still in a very early version, so don't expect it to do miracles.
Code must also be polished and refactored, but it's a continuous work in progress, so check out for the (currently frequent) updates.

It just works, basically. Well, at least since v0.1.0: earlier versions, in fact, had some dependency problem. Shame on me and my inexperience with gems. :(

I plan to extend and improve this gem in the future, e.g. adding wrappers for the most important UltraDNS functions.

Install
-------

Just run:

```
gem install ultrasoap
```

Add it to your Gemfile:

```
gem 'ultrasoap'
```

Finally, require it into your source code:

```
require 'ultrasoap'
```

Then create the file ~/.ultrasoap, which has to be in **YAML format**.
Fill the file with your Neustar credentials, like this:

```yaml
username: johndoe
password: secret
```

You can tune other settings as well, though only credentials are mandatory.

Example:

```yaml
log_file    : 'ultrasoap.log'
log         : false
log_level   : 'error'
test_wsdl   : 'https://testapi.ultradns.com/UltraDNS_WS/v01?wsdl'
prod_wsdl   : 'https://ultra-api.ultradns.com/UltraDNS_WS/v01?wsdl'
transactions: false
```

So basically you can tune log_file's path, logging level, test and production WSDL, and whether or not your client will use transactions.

Usage
-----

First off, instantiate UltraSOAP::Client:

```ruby
dl = UltraSOAP::Client.new()
```

Secondly, form the message and send it to the API server:

```ruby
# See SOAP API reference for explanations on parameters and calls
probes_message = {
  :pool_record_ID => pool_record_id.to_s,
  :sort_by        => 'PROBEDATA'
}
```

Now you are ready to send the call:

```ruby
probes_response = dl.send_request :get_probes_of_pool_record, probes_message
```

For those who didn't get it, the method *send_request* takes 2 parameters:
1) The symbol of the function to call.
2) The message containing the parameters for the function, as stated in the reference.

The response is an XML Nodeset, therefore you can perform XPath queries and everything:

```ruby
probes_response.xpath("//ProbeData").each |probe|
# Put your loop code here
...
...
end
```

There is also a rudimentary and experimental support for transactions.
Once you have instantiated the client, you can invoke the following methods:

```ruby
cl.start_transaction

cl.commit_transaction

cl.rollback_transaction
```

As soon as the transactions support will be thoroughly tested and will reach a stable status, I'll update the documentation with some example.
