## Note: this repository and related gem are not maintained anymore.

ultrasoap-ruby
==============

Ruby gem to interact with UltraDNS SOAP API.
This gem is still in a very early version, so don't expect it to do wonders.

It just works, basically.

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
dl.start_transaction

dl.commit_transaction

dl.rollback_transaction
```

As soon as the transactions support will be thoroughly tested and will reach a stable status, I'll update the documentation with some example.

Wrapper functions
-----------------

Although is possible to call all functions via the generic *send_request* method, I've started to implement some builtin function, which wraps the API functions themselves and should facilitate their invoking.

These functions require less writing and can be used without having to pre-form a message hash. They just need a couple of parameters.

All functions return a Nokogiri::Nodeset, just like send_request.

For a detailed description on response formats, take a look at the NUS API XML SOAP API guide by Neustar.

The current version supports the following functions:

```ruby

# Returns the current state of the Neustar network
# Return values: 'Good' if everything's ok, other values otherwise, nil in case of exceptions
network_status()

# Enumerate all Load Balancing pools for the required zone
# Parameters:
# - zone      => the name of the zone, *including* the trailing dot
# - pool_type => the type of the pool. Defaults to SB => SiteBacker . See the reference manual to learn more.

get_lb_pools(zone, pool_type='SB')

# Returns all the records for a certain load balancing pool
# Parameters:
# - pool_id => the ID of the pool
get_pool_records(pool_id)

# Update data for a Pool Record
# Returns true if the update was successful, false otherwise
# Parameters:
# - pool_record_id
# - pool_record_ip
# - action:
#   - "ForceActive-Test"
#   - "ForceActive-NoTest"
#   - "ForceFail-Test"
#   - "ForceFail-NoTest"
#   - "Normal"
# - priority
# - fail_over_delay
# - ttl
update_pool_record(pool_record_id, pool_record_ip, action="Normal", priority="1", fail_over_delay="0", ttl="60")

# Returns a list of probes for the given pool record
# Parameters:
# - poolRecordID
# - SortBy, possible values are: 
#   PROBEID
#   PROBEDATA
#   PROBEFAILSPECS
#   ACTIVE
#   POOLID
#   AGENTFAILSPECS
#   PROBEWEIGHT
#   BLEID
get_probes_of_pool_record(pool_record_id, sort_by="PROBEDATA")

# Returns notifications for a pool
# Parameters:
# - poolID: string
get_notifications_of_pool(pool_id)

```

More functions are on the way (lookup functions and other stuff).
