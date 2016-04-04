import ENV from 'ember-hearth/config/environment';

export function initialize(/* application */) {
  const storedUrl = localStorage.getItem(ENV.APP.LAST_URL_KEY);
  const currentUrl = document.location.href;
  const hasStoredUrl = typeof storedUrl === 'string';

  if (hasStoredUrl && currentUrl !== storedUrl) {
    document.location.replace(storedUrl);
  }

  window.onbeforeunload = function () {
    localStorage.setItem(ENV.APP.LAST_URL_KEY, document.location.href);
  };
}

export default {
  name: 'url-restore',
  initialize
};
