// =============================================
// StockPro — JS base
// =============================================
(function(){
  const THEME_KEY = 'sp-theme';

  function applySavedTheme(){
    const saved = localStorage.getItem(THEME_KEY) || 'light';
    document.documentElement.classList.toggle('dark-theme', saved === 'dark');
    const btn = document.getElementById('themeToggle');
    if(btn){
      const icon = btn.querySelector('i');
      if(icon){ icon.className = saved === 'dark' ? 'bi bi-sun' : 'bi bi-moon'; }
      btn.setAttribute('aria-pressed', saved === 'dark' ? 'true' : 'false');
      btn.title = saved === 'dark' ? 'Tema claro' : 'Tema escuro';
    }
  }

  function toggleTheme(){
    const isDark = document.documentElement.classList.toggle('dark-theme');
    localStorage.setItem(THEME_KEY, isDark ? 'dark' : 'light');
    const icon = document.querySelector('#themeToggle i');
    if(icon){ icon.className = isDark ? 'bi bi-sun' : 'bi bi-moon'; }
  }

  function initTooltips(){
    const triggers = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    triggers.forEach(el => new bootstrap.Tooltip(el));
  }

  // Toast helper
  window.showToast = function(msg, type){
    const container = document.getElementById('toastContainer') || (() => {
      const d = document.createElement('div');
      d.id = 'toastContainer';
      document.body.appendChild(d);
      return d;
    })();

    const toastEl = document.createElement('div');
    toastEl.className = 'toast align-items-center text-bg-' + (type||'primary') + ' border-0';
    toastEl.setAttribute('role','status');
    toastEl.innerHTML = '<div class="d-flex">\
      <div class="toast-body">'+ (msg||'Feito!') +'</div>\
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>\
    </div>';

    container.appendChild(toastEl);
    const t = new bootstrap.Toast(toastEl, { delay: 3000 });
    t.show();
  };

  document.addEventListener('DOMContentLoaded', function(){
    applySavedTheme();
    initTooltips();
    const themeBtn = document.getElementById('themeToggle');
    if(themeBtn){ themeBtn.addEventListener('click', toggleTheme); }
  });
})();
