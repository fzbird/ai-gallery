import { createDiscreteApi } from 'naive-ui';

const { message, notification, dialog, loadingBar } = createDiscreteApi(
  ['message', 'notification', 'dialog', 'loadingBar']
);
 
export { message, notification, dialog, loadingBar }; 