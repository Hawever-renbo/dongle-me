'use strict';
const state = {lang: 'en', checked: false, watch: false};
const text = {
  en: {elder:'Older adult',family:'Family',instructions:'Tap “I’m OK” to preview confirmation. Switch the family scenario to compare recent trends. Scroll inside either screen to explore.',check:'I’m OK — preview check-in',checked:'Preview check-in again',reset:'Reset',stable:'Stable trends',watch:'Changes to check',ready:'Ready to explore. All values are synthetic.',confirmed:'Check-in confirmation previewed. No notification has been sent.',attention:'Showing synthetic changes in recent trends. A friendly check-in is the intended next step.',scope:'Screenshot-based walkthrough. Check-ins and scenario changes happen only in this page; no notifications, calls, feedback or health data are sent. These are research estimates, not diagnoses or calibrated disease probabilities.',error:'A preview image could not load. Please try again or open the static screen gallery.'},
  zh: {elder:'老人端',family:'家人端',instructions:'点击“我很好”预览报平安确认。切换家人端情景，对比近期趋势；可在屏幕内滚动查看。',check:'我很好 — 预览报平安',checked:'再次预览报平安',reset:'重置',stable:'趋势平稳',watch:'变化值得关心',ready:'可以开始体验。所有数据均为模拟值。',confirmed:'已预览报平安确认，没有发送真实通知。',attention:'正在展示模拟的近期变化，下一步是与家人沟通关心。',scope:'这是基于界面截图的交互演示。报平安和情景切换仅在此页面中发生，不发送通知、电话、反馈或健康数据。五项分数为研究预估，不是诊断，也不是经过校准的疾病概率。',error:'预览图片加载失败，请重试或打开静态界面图集。'}
};
const byId = id => document.getElementById(id);
function render(message) {
  const t=text[state.lang], prefix=state.lang==='zh'?'assets/zh/':'assets/';
  byId('elder-label').textContent=t.elder; byId('family-label').textContent=t.family;
  for(const id of ['instructions','reset','stable','watch','scope']) { byId(id).textContent=t[id]; byId(id).lang=state.lang==='zh'?'zh-CN':'en'; }
  byId('check-in').textContent=state.checked?t.checked:t.check;
  for(const lang of ['en','zh']) byId('lang-'+lang).setAttribute('aria-pressed',String(state.lang===lang));
  for(const scenario of ['stable','watch']) byId(scenario).setAttribute('aria-pressed',String(state.watch===(scenario==='watch')));
  const elder=byId('elder-screen'), family=byId('family-screen');
  elder.src=prefix+(state.checked?'02-elder-check-in.png':'01-elder-home.png');
  family.src=prefix+(state.watch?'05-caregiver-watch.png':'06-caregiver-foldable.png');
  elder.alt=t.elder+' · '+(state.checked?t.confirmed:t.ready);
  family.alt=t.family+' · '+(state.watch?t.watch:t.stable);
  byId('demo-status').lang=state.lang==='zh'?'zh-CN':'en';
  byId('demo-status').textContent=t[message || (state.watch?'attention':state.checked?'confirmed':'ready')];
}
for(const lang of ['en','zh']) byId('lang-'+lang).addEventListener('click',()=>{state.lang=lang;render();});
byId('check-in').addEventListener('click',()=>{state.checked=true;render('confirmed');});
byId('reset').addEventListener('click',()=>{state.checked=false;state.watch=false;render();document.querySelectorAll('.screen').forEach(el=>{el.scrollTop=0;});});
for(const scenario of ['stable','watch']) byId(scenario).addEventListener('click',()=>{state.watch=scenario==='watch';render();byId('family-screen').parentElement.scrollTop=0;});
for(const id of ['elder-screen','family-screen']) byId(id).addEventListener('error',()=>{byId('demo-status').textContent=text[state.lang].error;});
render();
