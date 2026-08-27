(() => {
'use strict';
const c=document.getElementById('mxCanvas'); if(!c)return;
const x=c.getContext('2d',{alpha:false}); x.imageSmoothingEnabled=true;
const W=960,H=540,TAU=Math.PI*2;
const $=s=>document.querySelector(s);
const UI={score:$('#mxScore'),yards:$('#mxYards'),down:$('#mxDown'),hp:$('#mxHp'),meter:$('#mxMeter'),status:$('#mxStatus'),
 up:$('#mxUp'),left:$('#mxLeft'),right:$('#mxRight'),downBtn:$('#mxDownBtn'),smash:$('#mxSmash'),dash:$('#mxDash'),mutate:$('#mxMutate')};
const col={g:'#8aff2b',p:'#ff2d95',b:'#39d7ff',y:'#ffe53b',w:'#ffffff',k:'#030406'};
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v)),rand=(a,b)=>a+Math.random()*(b-a);
const input={up:false,down:false,left:false,right:false};
const S={mode:'title',t:0,last:performance.now(),score:0,yards:0,down:1,toGo:20,hp:100,meter:0,speed:21,world:0,spawn:.6,def:[],parts:[],flash:0,shake:0,banner:'',bannerT:0};
const P={lane:0,z:.18,vLane:0,smash:0,dash:0,inv:0,mutate:0};

const imgs={};
for(const [k,p] of Object.entries({
 dex:'assets/images/titanball94/dex-sheet.PNG',
 bru:'assets/images/titanball94/bruiser-sheet.PNG',
 bobby:'assets/images/titanball94/bobby94.PNG',
 juice:'assets/images/titanball94/sjuice94.PNG',
 loops:'assets/images/titanball94/loops94.PNG'
})){const im=new Image();im.src=p;imgs[k]=im}
const ready=k=>imgs[k]&&imgs[k].complete&&imgs[k].naturalWidth>0;

function proj(lane,z){
 const horizon=132,nearY=500;
 const zz=clamp(z,0,1),y=horizon+(nearY-horizon)*Math.pow(zz,1.35);
 const half=66+(W*.46-66)*Math.pow(zz,1.08);
 return {x:W/2+lane*half,y,scale:.18+.92*Math.pow(zz,1.25),half};
}
function field(){
 x.fillStyle='#03050a';x.fillRect(0,0,W,H);
 // stadium bowl
 const grad=x.createLinearGradient(0,0,0,H);grad.addColorStop(0,'#16051f');grad.addColorStop(.35,'#06131a');grad.addColorStop(1,'#030406');x.fillStyle=grad;x.fillRect(0,0,W,H);
 // crowd bands
 for(let r=0;r<4;r++){x.fillStyle=r%2?'#0a1217':'#120917';x.fillRect(0,34+r*22,W,18);for(let i=0;i<85;i++){x.fillStyle=Math.random()<.34?col.p:Math.random()<.5?col.g:col.b;x.fillRect((i*37+r*19)%W,38+r*22,2,2)}}
 // neon ribbon
 x.fillStyle='rgba(255,45,149,.18)';x.fillRect(0,116,W,7);x.fillStyle=col.p;x.fillRect(0,118,W,2);
 // perspective field polygon
 x.beginPath();x.moveTo(W/2-70,128);x.lineTo(W-32,H);x.lineTo(32,H);x.lineTo(W/2+70,128);x.closePath();
 const turf=x.createLinearGradient(0,128,0,H);turf.addColorStop(0,'#10280f');turf.addColorStop(1,'#174d18');x.fillStyle=turf;x.fill();
 // yard stripes + center
 for(let i=0;i<=10;i++){let z=i/10,p=proj(0,z);x.strokeStyle=i===10?col.y:'rgba(255,255,255,.28)';x.lineWidth=i===10?4:1.5;x.beginPath();x.moveTo(W/2-p.half,p.y);x.lineTo(W/2+p.half,p.y);x.stroke()}
 // sidelines
 x.strokeStyle=col.g;x.lineWidth=3;x.beginPath();x.moveTo(W/2-70,128);x.lineTo(32,H);x.moveTo(W/2+70,128);x.lineTo(W-32,H);x.stroke();
 // center markings
 for(let i=1;i<10;i++){const p=proj(0,i/10);x.fillStyle='rgba(255,255,255,.5)';x.font=`900 ${Math.max(8,18*p.scale)}px Barlow Condensed`;x.textAlign='center';x.fillText(String(i*10),W/2,p.y-4)}
 // goal
 const g=proj(0,.01);x.strokeStyle=col.y;x.lineWidth=6;x.beginPath();x.moveTo(g.x,g.y+5);x.lineTo(g.x,g.y-48);x.moveTo(g.x-38,g.y-48);x.lineTo(g.x+38,g.y-48);x.moveTo(g.x-38,g.y-48);x.lineTo(g.x-38,g.y-78);x.moveTo(g.x+38,g.y-48);x.lineTo(g.x+38,g.y-78);x.stroke();
 x.fillStyle='rgba(255,45,149,.88)';x.font='900 26px Barlow Condensed';x.textAlign='center';x.fillText('TITAN STADIUM',W/2,103);
}
function drawSprite(im,sx,sy,sw,sh,px,py,pw,ph,flip=false){
 if(!im||!im.complete||!im.naturalWidth)return false;
 x.save();if(flip){x.translate(px+pw,py);x.scale(-1,1);x.drawImage(im,sx,sy,sw,sh,0,0,pw,ph)}else x.drawImage(im,sx,sy,sw,sh,px,py,pw,ph);x.restore();return true
}
function player(){
 const p=proj(P.lane,.84);const sc=p.scale;
 x.fillStyle='rgba(0,0,0,.45)';x.beginPath();x.ellipse(p.x,p.y+21*sc,32*sc,9*sc,0,0,TAU);x.fill();
 if(P.mutate>0){x.strokeStyle=col.g;x.lineWidth=4;x.beginPath();x.arc(p.x,p.y,38+Math.sin(S.t*14)*6,0,TAU);x.stroke()}
 const w=94*sc,h=118*sc;
 if(!drawSprite(imgs.dex,1000,48,500,410,p.x-w/2,p.y-h*.78,w,h,false)){x.fillStyle=col.g;x.beginPath();x.arc(p.x,p.y,18*sc,0,TAU);x.fill()}
}
function defender(d){
 const p=proj(d.lane,d.z),sc=p.scale*(d.kind==='tank'?1.15:.9),w=84*sc,h=102*sc;
 x.fillStyle='rgba(0,0,0,.4)';x.beginPath();x.ellipse(p.x,p.y+16*sc,25*sc,7*sc,0,0,TAU);x.fill();
 if(d.kind==='ref'&&ready('bobby')){x.drawImage(imgs.bobby,p.x-w*.38,p.y-h*.74,w*.76,h);return}
 if(!drawSprite(imgs.bru,920,22,555,400,p.x-w/2,p.y-h*.72,w,h,true)){x.fillStyle=d.kind==='tank'?col.p:col.b;x.beginPath();x.arc(p.x,p.y,16*sc,0,TAU);x.fill()}
}
function particleBurst(px,py,color,n=14){
 for(let i=0;i<n;i++)S.parts.push({x:px,y:py,vx:rand(-170,170),vy:rand(-170,80),life:rand(.25,.7),color,size:rand(2,7)});
}
function spawn(){const kind=Math.random()<.14?'ref':Math.random()<.55?'speed':'tank';S.def.push({lane:rand(-.82,.82),z:.05,kind,dead:false});}
function start(){S.mode='play';S.score=0;S.yards=0;S.down=1;S.toGo=20;S.hp=100;S.meter=0;S.world=0;S.def=[];S.parts=[];S.banner='KICKOFF // SURVIVE';S.bannerT=1.2;P.lane=0;P.z=.84;P.smash=P.dash=P.inv=P.mutate=0}
function hitTest(d){return d.z>.73&&Math.abs(d.lane-P.lane)<(.13+(d.kind==='tank'?.05:0))}
function update(dt){
 S.t+=dt;S.flash=Math.max(0,S.flash-dt);S.shake=Math.max(0,S.shake-dt*40);S.bannerT=Math.max(0,S.bannerT-dt);
 if(S.mode!=='play')return;
 P.smash=Math.max(0,P.smash-dt);P.dash=Math.max(0,P.dash-dt);P.inv=Math.max(0,P.inv-dt);P.mutate=Math.max(0,P.mutate-dt);
 const move=1.55*dt;if(input.left)P.lane-=move;if(input.right)P.lane+=move;if(input.up)S.speed=Math.min(34,S.speed+14*dt);if(input.down)S.speed=Math.max(14,S.speed-18*dt);P.lane=clamp(P.lane,-.86,.86);
 const boost=P.dash>0?1.7:1;S.world+=S.speed*boost*dt;S.yards+=S.speed*boost*dt*.18;S.score+=Math.floor(S.speed*boost*dt*8);
 if(S.yards>=100){S.mode='win';S.banner='TOUCHDOWN // MUTANT X';S.bannerT=99;return}
 S.spawn-=dt;if(S.spawn<=0){spawn();S.spawn=rand(.48,.95)}
 for(const d of S.def){d.z+=dt*(.22+S.speed*.008)*(d.kind==='speed'?1.22:d.kind==='tank'?.9:1);if(!d.dead&&hitTest(d)){
   const pp=proj(d.lane,d.z);
   if(P.smash>0||P.mutate>0){d.dead=true;S.score+=900;S.meter=clamp(S.meter+18,0,100);S.shake=7;particleBurst(pp.x,pp.y,d.kind==='ref'?col.y:col.p,18)}
   else if(P.inv<=0){d.dead=true;P.inv=.75;const dmg=d.kind==='tank'?25:d.kind==='ref'?10:16;S.hp-=dmg;S.shake=11;S.flash=.18;particleBurst(pp.x,pp.y,col.p,20);S.down++;S.toGo=Math.max(1,20-(Math.floor(S.yards)%20));if(S.hp<=0||S.down>4){S.mode='lose';S.banner=S.hp<=0?'PLAYER DESTROYED':'TURNOVER ON DOWNS';S.bannerT=99}}
 }}
 S.def=S.def.filter(d=>!d.dead&&d.z<1.08);
 for(const p of S.parts){p.x+=p.vx*dt;p.y+=p.vy*dt;p.vy+=240*dt;p.life-=dt}S.parts=S.parts.filter(p=>p.life>0);
}
function text(t,px,py,size=24,color='#fff',align='center'){x.fillStyle=color;x.font=`900 ${size}px Barlow Condensed,Impact,sans-serif`;x.textAlign=align;x.textBaseline='middle';x.fillText(t,px,py)}
function render(){
 let sx=S.shake?rand(-S.shake,S.shake):0,sy=S.shake?rand(-S.shake*.45,S.shake*.45):0;x.save();x.translate(sx,sy);field();
 if(S.mode==='title'){x.fillStyle='rgba(0,0,0,.55)';x.fillRect(0,0,W,H);text('TITAN BALL',W/2,200,78,col.p);text('MUTANT X',W/2,274,70,col.g);text('3D STADIUM RESCUE BUILD',W/2,334,24,col.y);if(Math.floor(S.t*2)%2===0)text('TAP / PRESS START',W/2,430,30,'#fff')}
 else if(S.mode==='play'){for(const d of [...S.def].sort((a,b)=>a.z-b.z))defender(d);player();for(const p of S.parts){x.globalAlpha=clamp(p.life/.7,0,1);x.fillStyle=p.color;x.fillRect(p.x,p.y,p.size,p.size)}x.globalAlpha=1;if(S.bannerT>0){x.fillStyle='rgba(0,0,0,.68)';x.fillRect(250,145,460,50);text(S.banner,W/2,170,28,col.y)}}
 else {x.fillStyle='rgba(0,0,0,.62)';x.fillRect(0,0,W,H);text(S.mode==='win'?'TOUCHDOWN!':'GAME OVER',W/2,220,74,S.mode==='win'?col.g:col.p);text(S.banner,W/2,300,28,'#fff');text('TAP / ENTER TO RESTART',W/2,420,26,col.y)}
 if(S.flash>0){x.globalAlpha=.35;x.fillStyle='#fff';x.fillRect(0,0,W,H);x.globalAlpha=1}x.restore();
}
function sync(){UI.score.textContent=String(Math.floor(S.score)).padStart(6,'0');UI.yards.textContent=Math.min(100,Math.floor(S.yards));UI.down.textContent=`${S.down} & ${Math.ceil(S.toGo)}`;UI.hp.textContent=Math.max(0,S.hp);UI.meter.textContent=`${Math.floor(S.meter)}%`;UI.status.textContent=S.mode==='play'?'LIVE':S.mode==='win'?'TOUCHDOWN':S.mode==='lose'?'DEAD':'PRESS START';UI.mutate.textContent=S.meter>=100?'⚡ MUTATION READY':'⚡ MUTATION'}
function smash(){if(S.mode!=='play'){start();return}if(P.smash<=0)P.smash=.28}
function dash(){if(S.mode!=='play'){start();return}if(P.dash<=0)P.dash=.32}
function mutate(){if(S.mode!=='play'){start();return}if(S.meter>=100){S.meter=0;P.mutate=4;P.inv=4;S.banner='MUTATION OVERDRIVE';S.bannerT=1}}
function hold(el,key){const off=()=>{input[key]=false;el?.classList.remove('active')};el?.addEventListener('pointerdown',e=>{e.preventDefault();input[key]=true;el.classList.add('active');el.setPointerCapture?.(e.pointerId)});['pointerup','pointercancel','lostpointercapture'].forEach(ev=>el?.addEventListener(ev,off))}
hold(UI.up,'up');hold(UI.downBtn,'down');hold(UI.left,'left');hold(UI.right,'right');UI.center?.addEventListener('pointerdown',e=>{e.preventDefault();input.up=input.down=input.left=input.right=false});
[[UI.smash,smash],[UI.dash,dash],[UI.mutate,mutate]].forEach(([el,fn])=>el?.addEventListener('pointerdown',e=>{e.preventDefault();fn()}));
c.addEventListener('pointerdown',e=>{e.preventDefault();if(S.mode!=='play')start()});
window.addEventListener('keydown',e=>{if(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight','Space'].includes(e.code))e.preventDefault();if((e.code==='Enter'||e.code==='Space')&&S.mode!=='play'){start();return}if(e.code==='ArrowUp'||e.code==='KeyW')input.up=true;if(e.code==='ArrowDown'||e.code==='KeyS')input.down=true;if(e.code==='ArrowLeft'||e.code==='KeyA')input.left=true;if(e.code==='ArrowRight'||e.code==='KeyD')input.right=true;if(e.code==='KeyX')smash();if(e.code==='KeyC'||e.code==='Space')dash();if(e.code==='KeyV')mutate()});
window.addEventListener('keyup',e=>{if(e.code==='ArrowUp'||e.code==='KeyW')input.up=false;if(e.code==='ArrowDown'||e.code==='KeyS')input.down=false;if(e.code==='ArrowLeft'||e.code==='KeyA')input.left=false;if(e.code==='ArrowRight'||e.code==='KeyD')input.right=false});
window.addEventListener('blur',()=>{input.up=input.down=input.left=input.right=false});
document.addEventListener('visibilitychange',()=>{if(document.hidden)input.up=input.down=input.left=input.right=false});
function loop(now){const dt=Math.min(.033,(now-S.last)/1000||0);S.last=now;update(dt);sync();render();requestAnimationFrame(loop)}
sync();requestAnimationFrame(loop);
})();