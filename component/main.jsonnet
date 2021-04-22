// main template for minio
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.minio;
local instance = inv.parameters._instance;

local namespace = kube.Namespace(params.namespace) {
  metadata+: {
    labels+: {
      app: 'minio',
      'app.kubernetes.io/name': 'minio-' + instance,
      'app.kubernetes.io/instance': 'minio-' + instance,
    },
  },
};

local adminCredentials = kube.Secret(params.adminCredentials.secretName) {
  metadata+: {
    namespace: params.namespace,
  },
  // need to use stringData here for secret reveal to work
  // use keys which bitnami/minio Helm chart expects for the credentials secret
  stringData+: {
    accesskey: params.adminCredentials.accessKey,
    secretkey: params.adminCredentials.secretKey,
  },
};

// Define outputs below
{
  '01_adminCredentials': adminCredentials,
}
