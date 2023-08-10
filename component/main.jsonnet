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

local rootUser =
  if std.objectHas(params.adminCredentials, 'accessKey') then
    std.trace(
      'parameter `adminCredentials.accessKey` is deprecated, please use parameter `adminCredentials.rootUser` instead',
      params.adminCredentials.accessKey
    )
  else params.adminCredentials.rootUser;

local rootPassword =
  if std.objectHas(params.adminCredentials, 'secretKey') then
    std.trace(
      'parameter `adminCredentials.secretKey` is deprecated, please use parameter `adminCredentials.rootPassword` instead',
      params.adminCredentials.secretKey
    )
  else params.adminCredentials.rootPassword;

local adminCredentials = kube.Secret(params.adminCredentials.secretName) {
  metadata+: {
    namespace: params.namespace,
  },
  // need to use stringData here for secret reveal to work
  // use keys which bitnami/minio Helm chart expects for the credentials secret
  stringData+: {
    rootUser: rootUser,
    rootPassword: rootPassword,
  },
};

// Define outputs below
{
  '00_namespace': namespace,
  '01_adminCredentials': adminCredentials,
}
