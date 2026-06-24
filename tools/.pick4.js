const d = require("./cefr-wordlist.json");
const rank = { A1: 1, A2: 2, B1: 3, B2: 4, C1: 5, C2: 6 };
const okWord = (w) => { const l = d[w.toLowerCase()]; return l ? rank[l] <= 3 : false; };

const edges = [
  ["news","paper"],["paper","back"],["paper","work"],["paper","clip"],["clip","board"],
  ["back","ground"],["back","drop"],["back","pack"],["back","fire"],["back","yard"],["ground","work"],
  ["ground","floor"],["floor","board"],["floor","lamp"],["lamp","light"],["work","sheet"],["work","shop"],
  ["work","book"],["work","out"],["sheet","music"],["music","box"],["box","office"],["box","car"],
  ["office","worker"],["car","wash"],["car","park"],["wash","room"],["birth","day"],["day","light"],
  ["day","time"],["day","dream"],["day","care"],["light","house"],["house","work"],["house","hold"],
  ["house","wife"],["house","boat"],["home","work"],["home","town"],["sun","light"],["sun","flower"],
  ["sun","set"],["sun","burn"],["sun","rise"],["moon","light"],["moon","walk"],["out","side"],["out","door"],
  ["out","break"],["out","line"],["out","fit"],["out","post"],["side","walk"],["side","line"],["side","board"],
  ["walk","way"],["door","step"],["door","bell"],["door","way"],["door","man"],["way","out"],["way","side"],
  ["bed","room"],["bed","time"],["bed","side"],["bath","room"],["class","room"],["show","room"],["ball","room"],
  ["board","room"],["board","game"],["board","walk"],["coffee","table"],["coffee","cup"],["coffee","shop"],
  ["table","tennis"],["table","top"],["table","cloth"],["table","spoon"],["tennis","ball"],["foot","ball"],
  ["foot","print"],["foot","step"],["foot","note"],["foot","hill"],["hand","bag"],["hand","ball"],["hand","shake"],
  ["hand","out"],["hand","writing"],["snow","ball"],["snow","man"],["snow","fall"],["snow","storm"],["ball","park"],
  ["ball","point"],["ball","game"],["post","card"],["post","office"],["post","man"],["post","box"],["card","board"],
  ["card","game"],["black","board"],["black","bird"],["white","board"],["key","board"],["key","hole"],["key","word"],
  ["key","chain"],["key","ring"],["game","show"],["show","case"],["ice","cream"],["cream","cheese"],["cheese","cake"],
  ["cup","cake"],["cup","board"],["tea","cup"],["tea","bag"],["tea","time"],["egg","cup"],["time","table"],
  ["time","line"],["time","out"],["summer","time"],["over","time"],["rain","coat"],["rain","drop"],["rain","fall"],
  ["rain","water"],["water","fall"],["water","front"],["water","way"],["water","proof"],["sea","side"],["sea","food"],
  ["sea","front"],["sea","horse"],["fire","man"],["fire","place"],["fire","work"],["fire","fly"],["fire","wood"],
  ["fire","side"],["dog","house"],["cat","food"],["cat","walk"],["hair","cut"],["hair","brush"],["hair","style"],
  ["hair","band"],["tooth","brush"],["tooth","pick"],["shoe","box"],["shoe","shop"],["week","end"],["week","day"],
  ["arm","chair"],["wheel","chair"],["high","chair"],["chair","man"],["text","book"],["note","book"],["note","pad"],
  ["cook","book"],["book","shop"],["book","case"],["book","club"],["book","mark"],["bird","house"],["bird","bath"],
  ["dream","land"],["land","mark"],["land","slide"],["milk","shake"],["milk","man"],["butter","fly"],["butter","cup"],
  ["butter","milk"],["foot","wear"],["over","coat"],["over","head"],["over","night"],["night","club"],["night","fall"],
  ["down","town"],["down","fall"],["down","stairs"],["down","load"],["finger","print"],["finger","tip"],
  ["green","house"],["lip","stick"],["wall","paper"],["wall","flower"],["play","ground"],["play","room"],["play","time"],
  ["play","house"],["rain","forest"],["road","side"],["road","map"],["road","block"],["road","work"],["road","trip"],
  ["eye","ball"],["eye","brow"],["check","out"],["check","book"],["check","list"],["pan","cake"],["fish","cake"],
  ["pin","ball"],["base","ball"],["score","board"],["score","card"],["hand","book"],["pass","word"],["cross","word"],
  ["watch","dog"],["watch","man"],["watch","tower"],["wrist","watch"],["stop","watch"],["lap","top"],["roof","top"],
  ["hill","top"],["under","water"],["under","ground"],["fire","wood"],["video","game"],["head","line"],["head","light"],
  ["head","ache"],["head","phone"],["head","band"],["bag","pipe"],["pipe","line"],["chain","saw"],["food","chain"],
  ["saw","dust"],["dust","bin"],["bin","bag"],["fast","food"],["break","fast"],["lunch","box"],["lunch","time"],
  ["lunch","break"],["mail","box"],["mail","man"],["tool","box"],["sand","box"],["match","box"],
];
const adj = {};
for (const [a,b] of edges) (adj[a] ||= []).push(b);
const results = [], seen = new Set();
function dfs(p){ if(p.length===9){const k=p.join(" ");if(!seen.has(k)){seen.add(k);results.push([...p]);}return;}
  for(const n of adj[p[p.length-1]]||[]){ if(p.includes(n)||!okWord(n))continue; p.push(n);dfs(p);p.pop(); if(results.length>300000)return; } }
for(const s of Object.keys(adj)){ if(okWord(s)) dfs([s]); }

// pairs already used by my 11 hand-authored chains:
const used = [
 ["high","school","bus","stop","watch","dog","house","work","shop"],
 ["ice","cream","cheese","cake","shop","window","box","office","worker"],
 ["summer","time","table","tennis","ball","park","way","side","line"],
 ["news","paper","back","ground","work","book","mark","up","town"],
 ["rain","drop","out","door","bell","boy","friend","ship","yard"],
 ["sun","flower","bed","side","walk","way","out","line","up"],
 ["wall","paper","clip","board","game","show","room","service","station"],
 ["over","time","out","break","fast","food","chain","saw","dust"],
 ["sea","horse","back","fire","wood","land","mark","down","fall"],
 ["cross","word","play","ground","floor","lamp","light","house","hold"],
 ["pop","corn","field","work","sheet","music","box","car","wash"],
];
const usedPairs = new Map();
for (const c of used) for (let i=0;i<8;i++) usedPairs.set(c[i]+">"+c[i+1], 2); // treat as saturated

// greedily pick 4 chains minimizing new repeats + reused start words
const usedStarts = new Set(used.map(c=>c[0]));
const usedWordsAll = new Set(used.flat());
const picked = [];
const chosen = new Set();
while (picked.length < 4) {
  let best=null,bestCost=Infinity;
  for (const r of results) {
    if (chosen.has(r.join(" "))) continue;
    let cost=0;
    for (let i=0;i<8;i++){ const c=usedPairs.get(r[i]+">"+r[i+1])||0; if(c>0) cost+=10; }
    if (usedStarts.has(r[0])) cost+=5;
    for (const w of r) if (usedWordsAll.has(w)) cost+=0.3;
    if (cost<bestCost){bestCost=cost;best=r;}
  }
  if(!best) break;
  picked.push([best,bestCost]); chosen.add(best.join(" ")); usedStarts.add(best[0]);
  for(let i=0;i<8;i++){const k=best[i]+">"+best[i+1];usedPairs.set(k,(usedPairs.get(k)||0)+1);}
  for(const w of best) usedWordsAll.add(w);
}
console.log("candidates:", results.length);
for (const [r,c] of picked) console.log("cost="+c.toFixed(1), r.join(" "));
