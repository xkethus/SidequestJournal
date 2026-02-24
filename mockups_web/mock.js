const screen = document.getElementById('screen');
const titleIn = document.getElementById('title');
const promptIn = document.getElementById('prompt');
const categoryIn = document.getElementById('category');
const levelSelect = document.getElementById('levelSelect');

function setTemplate(t){
  screen.dataset.template = t;
  document.querySelectorAll('[data-template]').forEach(btn=>{
    if(btn.classList.contains('pill')){
      btn.classList.toggle('active', btn.dataset.template === t);
    }
  });
}

function setLevel(l){
  screen.dataset.level = String(l);
  const txt = `Nivel ${l}`;
  document.getElementById('level').textContent = txt;
  document.getElementById('level2').textContent = txt;
  const lb = document.getElementById('levelB');
  if(lb) lb.textContent = txt;
}

function syncText(){
  const t = titleIn.value;
  const p = promptIn.value;
  const c = categoryIn.value;

  // A
  document.getElementById('promptOut').textContent = p;
  const catMetaA = document.getElementById('catMetaA');
  if(catMetaA) catMetaA.textContent = c.toLowerCase();

  // B
  const promptOutB = document.getElementById('promptOutB');
  const chipB = document.getElementById('chipB');
  if(promptOutB) promptOutB.textContent = p;
  if(chipB) chipB.textContent = c.toLowerCase();

  // C
  const promptOutC = document.getElementById('promptOutC');
  const catC = document.getElementById('catC');
  if(promptOutC) promptOutC.textContent = p;
  if(catC) catC.textContent = c.toLowerCase();

  // D
  const promptOutD = document.getElementById('promptOutD');
  const catD = document.getElementById('catD');
  if(promptOutD) promptOutD.textContent = p;
  if(catD) catD.textContent = c.toLowerCase();
}

// wire

document.querySelectorAll('button.pill').forEach(btn=>{
  btn.addEventListener('click', ()=> setTemplate(btn.dataset.template));
});

levelSelect.addEventListener('change', ()=> setLevel(levelSelect.value));
[titleIn, promptIn, categoryIn].forEach(el=> el.addEventListener('input', syncText));

// init
setTemplate('a');
setLevel(levelSelect.value);
syncText();
