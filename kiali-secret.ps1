
$istioNamespace = 'istio-system'
$KIALI_USERNAME='admin'
$KIALI_PASSPHRASE='admin'

# create username password secret
$KIALI_USERNAME=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($KIALI_USERNAME))
$KIALI_PASSPHRASE=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($KIALI_PASSPHRASE))

"apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: $istioNamespace
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE" | kubectl apply -f -
