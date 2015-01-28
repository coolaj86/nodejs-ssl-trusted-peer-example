nodejs-ssl-trusted-peer-example
===============================

This is a working example of a trusted-peer setup using HTTPS / SSL.

* You are your own Root Certificate Authority
* Your primary server has a certificate signed by your CA
* Your clients also have certificates signed by your CA
* Client/Peer certificates which have not been signed by a trusted authority (your CA) are rejected.
* The built-in CA list is *replaced* rather than appended to (see [ssl-root-cas](https://github.com/coolaj86/node-ssl-root-cas) for appending).

This is a kind of "part 2" to
[coolaj86/nodejs-self-signed-certificate-example](https://github.com/coolaj86/nodejs-self-signed-certificate-example).

See also:
* [nategood/node-auth](https://github.com/nategood/node-auth).
* [coolaj86/Painless-Self-Signed-Certificates-in-node](https://github.com/coolaj86/node-ssl-root-cas/wiki/Painless-Self-Signed-Certificates-in-node.js)

Test for yourself
---

An example that works.

```bash
example
├── make-root-ca-and-certificates.sh
├── package.json
├── serve.js
├── request.sh
└── request.js
```

### Get the repo

```bash
git clone git@github.com:coolaj86/nodejs-ssl-trusted-peer-example.git
pushd nodejs-ssl-trusted-peer-example
npm install
```

**For the super impatient**:

```bash
bash test.sh
```

This will

* create all of the keys
* ask you to create a file to protect your p12 file
* (needed to allow Chrome, Safari, and other apps to use your key + crt in OS X Keychain Access)
* run the tests and print happy messages

### Create certificates for your FQDN

`local.foobar3000.com` points to `localhost`, so it's ideal for your first test.

```bash
bash make-root-ca-and-certificates.sh local.foobar3000.com 8043
```

This will ask you to create a passphrase to protect your p12 file.
If you forget the passphrase, the file can easily be recreated later (see source in the file).

For the purposes of this tutorial, I recommend choosing 'secret'

```
certs/
├── ca
│   ├── my-root-ca.crt.pem
│   ├── my-root-ca.key.pem
│   └── my-root-ca.srl
├── client
│   ├── my-app-client.crt.pem
│   ├── my-app-client.key.pem
│   ├── my-app-client.p12
│   └── my-root-ca.crt.pem
├── server
│   ├── my-root-ca.crt.pem
│   ├── my-server.crt.pem
│   └── my-server.key.pem
└── tmp
    ├── my-app-client.csr.pem
    └── my-server.csr.pem
```

### Run the server

```bash
node ./serve.js 8043 &
# use `fg` and `ctrl+c` to kill
```


### Test in a client

Test in node.js

```bash
node ./request.js local.foobar3000.com 8043
```

Test with cURL

```bash
curl -v -s "https://local.foobar3000.com:8043" \
  --key certs/client/my-app-client.key.pem \
  --cert certs/client/my-app-client.crt.pem \
  --cacert certs/client/my-root-ca.crt.pem
```

Visit in a web browser

<https://local.foobar3000.com:8043>

To get rid of the browser errors and warnings, simply add the certificate from the `client` folder
to your list of certificates by alt-clicking "Open With => Keychain Access"
on `my-root-ca.crt.pem` and also on `my-app-client.p12`
(you will need to use the passphrase you created earlier)

You do have to set `Always Trust` a few times
[as explained](http://www.robpeck.com/2010/10/google-chrome-mac-os-x-and-self-signed-ssl-certificates/#.U8RqrI1dVd8) by Rob Peck.

Now season to taste
---

You can poke around in the files for generating the certificates, 
but all you really have to do is replace `local.foobar3000.com`
with your very own domain name.

Show me the Magic!
====

You have 3 different certificates with private / public pairs:

* The Root CA (CN=example.com), which is used to sign the other certs
* The Server Cert (CN=local.foobar3000.com), which is signed by the Root CA
* The Peer Cert (CN=client.example.net), which is signed by the Root CA

Since the server's CA list is overwritten with *only* the self-signed Root CA
only clients which have a certificate signed by that CA
will be trusted
(or potentially something else in the same certificate chain).

### On the server

```javascript
https.createServer({
  key: fs.readFileSync(path.join(__dirname, 'certs', 'server', 'my-server.key.pem'))
, ca: [ fs.readFileSync(path.join(__dirname, 'certs', 'server', 'my-root-ca.crt.pem'))]
, cert: fs.readFileSync(path.join(__dirname, 'certs', 'server', 'my-server.crt.pem'))
, requestCert: true
, rejectUnauthorized: true
})
```

* `requestCert` asks the client to identify itself.
* `rejectUnauthorized` prevents clients that aren't in the CA chain from being accepted.

If you need to selectively trust certain servers and clients when serving and making requests,
or also serve to public clients you may need to have multiple servers and clients.
[ssl-root-cas](https://github.com/coolaj86/node-ssl-root-cas) will probably help.

### In the client

```javascript
var options
  ;

options = {
  host: 'local.foobar3000.com'
, port: 8043
, path: '/'
, ca: [ fs.readFileSync(path.join(__dirname, 'certs', 'client', 'my-root-ca.crt.pem')) ]
, key: fs.readFileSync(path.join(__dirname, 'certs', 'client', 'my-app-client.key.pem'))
, cert: fs.readFileSync(path.join(__dirname, 'certs', 'client', 'my-app-client.crt.pem'))
};
options.agent = new https.Agent(options);

https.request(options, handler);
```

The node example for this (<http://nodejs.org/api/https.html>) is a bit confusing.
I'll have to read the source to better understand why the options are laid out as such.

What About WebSockets?
---

Viola: https://groups.google.com/forum/#!topic/nodejs/KJPk8aibQHY

Other SSL Resources
=========

Zero-Config clone 'n' run (tm) Repos:


* [io.js / node.js HTTPS SSL Example](https://github.com/coolaj86/nodejs-ssl-example)
* [io.js / node.js HTTPS SSL Self-Signed Certificate Example](https://github.com/coolaj86/nodejs-self-signed-certificate-example)
* [io.js / node.js HTTPS SSL Trusted Peer Client Certificate Example](https://github.com/coolaj86/nodejs-ssl-trusted-peer-example)
* [SSL Root CAs](https://github.com/coolaj86/node-ssl-root-cas)

Articles

* [http://greengeckodesign.com/blog/2013/06/15/creating-an-ssl-certificate-for-node-dot-js/](Creating an SSL Certificate for node.js)
* [http://www.hacksparrow.com/express-js-https-server-client-example.html/comment-page-1](HTTPS Trusted Peer Example)
* [How to Create a CSR for HTTPS SSL (demo with name.com, node.js)](http://blog.coolaj86.com/articles/how-to-create-a-csr-for-https-tls-ssl-rsa-pems/)
* [coolaj86/Painless-Self-Signed-Certificates-in-node](https://github.com/coolaj86/node-ssl-root-cas/wiki/Painless-Self-Signed-Certificates-in-node.js)
