ultrasoap-ruby
==============

Ruby gem for UltraDNS SOAP API

Install
-------

Just run:

```
gem install ultrasoap
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
