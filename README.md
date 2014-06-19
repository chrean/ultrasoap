ultrasoap-ruby
==============

Ruby gem for UltraDNS SOAP API

Install
-------

Just run:

```
gem install ultrasoap
```

Then create the file ~/.ultrasoap with your Neustar credentials, like this:

```
username: johndoe
password: secret
```

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

The response is an XML Nodeset, therefore you can perform XPath queries and everything:

```ruby
probes_response.xpath("//ProbeData").each |probe|
# Put your loop code here
...
...
end
```
