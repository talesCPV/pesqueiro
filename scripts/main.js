
/* VARIABLES */

var main_data = new Object
var today = new Date()
var meses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro']
var semana = ['Dom','Seg','Ter','Qua','Qui','Sex','Sab']
/*  FUNCTIONS  */

function forceHTTPS(){
    location.protocol !== 'https:' ? location.replace(`https:${location.href.substring(location.protocol.length)}`) : null
}


/*  DATABASE  */
function queryDB(params,cod){
    const access = main_data.dashboard == undefined ? -1 : main_data.dashboard.data.access
    const hash = localStorage.getItem('hash') == undefined ? 0 : localStorage.getItem('hash')
    const data = new URLSearchParams()
        data.append("access", access)
        data.append("hash", hash)
        data.append("cod", cod)
        data.append("params", JSON.stringify(params))

    const myRequest = new Request("backend/query_db.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text())        
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));
            } 
        });
    });      
}

function getConfig(field){
    const data = new URLSearchParams();        
        data.append("user", localStorage.getItem('id_user'));
        data.append("field", field);
        data.append("file",'config.json');
    const myRequest = new Request("backend/getConfig.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function setConfig(field,value){
    const data = new URLSearchParams();        
    data.append("user", localStorage.getItem('id_user'));
    data.append("field", field);
    data.append("file",'config.json');
    data.append("value", value);
    const myRequest = new Request("backend/setConfig.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function loadTXT(file='templateNFe.txt'){
        const data = new URLSearchParams();        
            data.append("file",file);
        const myRequest = new Request("backend/getFile.php",{
            method : "POST",
            body : data
        });

        return new Promise((resolve,reject) =>{
            fetch(myRequest)
            .then(function (response){
                if (response.status === 200) {                 
                    resolve(response.text());                    
                } else { 
                    reject(new Error("Houve algum erro na comunicação com o servidor"));                    
                } 
            });
        }); 
}

/*  ABAS */

function pictab(e){
    const tab = e.id
    const content = document.querySelectorAll(".tab");
    for (let i = 0; i < content.length; i++) {
        const sel_tab = document.querySelector('#tab-'+content[i].id)

        if(content[i].id == tab.split('-')[1]){
            content[i].style.display = "block"
            sel_tab.classList.add("check-tab")
        }else{
            content[i].style.display = "none"
            sel_tab.classList.remove("check-tab")
        }
    }
}
 /* CHECK USER MAIL */

    function checkUserMail(){
        const params = new Object;
            params.hash = localStorage.getItem('hash')

        const myPromisse = queryDB(params,'USR-3');
        myPromisse.then((resolve)=>{
            const json = JSON.parse(resolve)[0]
            const unread = json.new_mail
            document.querySelector('#mail-badge').innerHTML = unread!='0' ? unread : ''
//            document.querySelector('#mail-badge-mobile').innerHTML = document.querySelector('#mail-badge').innerHTML
        })
    }

 /*  MENU  */ 
function openMenu(){

    var drop = 0
    const data = new URLSearchParams();        
        data.append("hash", localStorage.getItem('hash'));
    const myRequest = new Request("backend/openMenu.php",{
        method : "POST",
        body : data
    });

    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){        
            if (response.status === 200) { 
                resolve(response.text())
            } else {
                reject(new Error("Houve algum erro na comunicação com o servidor"))
            }
        })
    })

    myPromisse.then((resolve)=>{      
        const menu_data = JSON.parse(resolve)
        const menu = document.querySelector('.menu')
        menu.innerHTML = ''//usr_menu
        pushMenu(menu, menu_data)
        checkUserMail()
        addShortcut()

    });

    function pushMenu(menu, obj){
//        menu.innerHTML = ''
        for( let i=0; i<obj.length; i++){
            main_data.dashboard.data.access = obj[i].access 
            const li = document.createElement('li')                 
            const a = document.createElement('a')

            if(obj[i].hasOwnProperty('class')){
                li.className = obj[i].class
            }
            if(obj[i].hasOwnProperty('href')){
                a.href = obj[i].href
            }            

            a.innerHTML = obj[i].modulo
            if (obj[i].itens.length > 0 ){
                const lbl = document.createElement('label')
                lbl.htmlFor = `drop-${drop}`
                lbl.classList = 'toggle'
                lbl.innerHTML = obj[i].modulo + ' ▸'  
                li.appendChild(lbl)
                li.appendChild(a)
                if(obj[i].modulo == '@username'){
                    a.innerHTML = '@'+localStorage.getItem('nome').toLowerCase()                    
                    lbl.innerHTML = localStorage.getItem('email').toLowerCase()
                    const span = document.createElement('span')
                    span.className = 'badge' 
                    span.id = 'mail-badge'
                    a.appendChild(span)
//                    lbl.appendChild(span)
                }

                const ckb = document.createElement('input')
                ckb.type = 'checkbox';
                ckb.id = `drop-${drop}`
                drop++
                li.appendChild(ckb)

                if(obj[i].itens.length > 0){
                    const ul = document.createElement('ul')  
                    for(let j=0; j<obj[i].itens.length; j++){
                        pushMenu(ul,obj[i].itens[j])
                    }                                         
                    li.appendChild(ul)
                }
            }else{
                a.addEventListener('click',()=>{
                    main_data.dashboard.data.access = obj[i].access                              
                    openHTML(obj[i].link,obj[i].janela,obj[i].label,{},obj[i].width)
                })    
                a.addEventListener('contextmenu',(e)=>{
                    e.preventDefault()
                    if(confirm('Criar atalho na área de trabalho?')){
                        const myConfig = getConfig('shortcut')
                        myConfig.then((response)=>{
                            const json = response != '' ? JSON.parse(JSON.parse(response)) : []
                            const shortcut = new Object
                            shortcut.name = obj[i].modulo 
                            shortcut.access = obj[i].access
                            shortcut.link = obj[i].link
                            shortcut.icone = obj[i].icone
                            shortcut.janela = obj[i].janela
                            shortcut.label = obj[i].label
                            shortcut.width = obj[i].width
                            shortcut.x = 100
                            shortcut.y = 100
                            json.push(shortcut)
                            setConfig('shortcut' , JSON.stringify(json))
                            .then((resolve)=>{
                                addShortcut()
                                main_data.dashboard.data.shortcut = json.shortcut
                            })
                        })
                    }
                })     
                li.appendChild(a)                
            }
            menu.appendChild(li)
        }
    }
}

function addShortcut(){
    const myConfig = getConfig('shortcut')
    myConfig.then((response)=>{
        const main = document.querySelector('#main-screen')
        const icones = document.querySelectorAll('.icone')
        const json = response != '' ? JSON.parse(JSON.parse(response)) : new Object
        main_data.dashboard.data.shortcut = json
        
        for(let i=0; i<icones.length; i++){
            icones[i].remove()
        }

        for(let i=0; i<json.length; i++){
            const div = document.createElement('div')
            const label = document.createElement('p')
            div.className = 'icone'

            label.innerHTML= json[i].name
            div.appendChild(label)

            const icon = document.createElement('span')
            icon.className = `mdi ${json[i].icone}`
            div.appendChild(icon)

            div.addEventListener('mousedown',(e)=>{
            
                const x = parseInt(div.style.left)
                const y = parseInt(div.style.top)
                const pos = [x,y,e.clientX, e.clientY]
                document.onmousemove = (e,p=pos)=>{
                    e.preventDefault();                  
                    const left = p[0]-p[2]+e.clientX
                    const top = p[1]-p[3]+e.clientY
                    left >= 0 ? div.style.left =  left+'px' : null
                    top >= 60 ? div.style.top = top +'px' : null
                }
        
                document.onmouseup = (e,p=pos)=>{
                    e.preventDefault()
                    const sc = main_data.dashboard.data.shortcut
                    const move = (e.clientX != p[2] || e.clientY != p[3])
                    for(let j=0; j<sc.length; j++){
                        if(sc[j].link == json[i].link){
                            sc[i].x = p[0]-p[2]+e.clientX
                            sc[i].y = p[1]-p[3]+e.clientY                      
                            setConfig('shortcut' , JSON.stringify(sc))
                        }
                    }

                    /* icon click */
                    if(!move && e.button == 0){
                        main_data.dashboard.data.access = json[i].access 
                        openHTML(json[i].link,json[i].janela,json[i].label,{},json[i].width)
                    }

                    document.onmouseup = null;
                    document.onmousemove = null;
                }
            
            })           

            div.addEventListener('contextmenu',(e)=>{
                e.preventDefault()
            
                const tbl = []
                const obj = new Object
                obj.label = 'Deletar Atalho?'
                obj.link = ()=>{
                    const sc = main_data.dashboard.data.shortcut
                    for(let j=0; j<sc.length; j++){
                        if(sc[j].link == json[i].link){
                            sc.splice(i,1)
                            setConfig('shortcut' , JSON.stringify(sc))
                            addShortcut()
                        }
                    }
                    div.style.left = '0'
                }
                tbl.push(obj)
                menuContext(tbl,e)
            })

            div.style.left = json[i].x + 'px'
            div.style.top = json[i].y + 'px'
            main.appendChild(div)
        }
    })
}

/* IMAGE */

function aspect_ratio(img,cvw=300, cvh=300){
    out = [0,0,cvw,cvh]
    w = img.width
    h = img.height
    
    if(w >= h){
        out[3] = cvh/(w/h)
        out[1] = (cvh - out[3]) / 2
    }else{
        out[2] = cvw/(h/w)
        out[0] = (cvw - out[2]) / 2
    }
    return out
}

function showFile(idFile='up_file',idCanvas='cnvImg'){
    const inputFile = document.getElementById(idFile)
    if (inputFile.files && inputFile.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {            
            var ctx = document.getElementById(idCanvas)
            if (ctx.getContext) {
                ctx = ctx.getContext('2d');
                let preview = new Image();
                preview.onload = function () {
                    ar = aspect_ratio(preview,ctx.width,ctx.height) 
                    ctx.canvas.width = ar[2]
                    ctx.canvas.height = ar[3]
                    ctx.clearRect(0, 0, 300,300);
                    ctx.drawImage(preview, 0, 0,preview.width,preview.height,0,0,ar[2],ar[3]);
                };
                preview.src = e.target.result
            }
        }
        reader.readAsDataURL(inputFile.files[0]);
    }
}

function loadImg(filename, id='cnvImg',efect='normal') {
    var ctx = document.getElementById(id);     
    try{
        if (ctx.getContext) {
            ctx = ctx.getContext('2d');
            ctx.clearRect(0, 0, ctx.width, ctx.height);
            var img = new Image();
            img.onload = function () {
                ar = aspect_ratio(img,ctx.width,ctx.height)                
                ctx.canvas.width = ar[2]
                ctx.canvas.height = ar[3]
                ctx.globalCompositeOperation = efect
                ctx.drawImage(img, 0, 0,img.width,img.height,0,0,ar[2],ar[3]);
            };        
            img.src = filename+'?'+new Date().getTime()
        }
    }catch{
        console.error('Imagem não existe!')
    }

}

/* ARQUIVO DE LOG */

function setLog(line){
    const now = new Date
    line = line.normalize("NFD").replace(/[\u0300-\u036f]/g, "")
    const data = new URLSearchParams();        
        data.append("line",line);
        data.append("hash",localStorage.getItem('hash'));
    const myRequest = new Request("backend/setLog.php",{
        method : "POST",
        body : data
    })
    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());             
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        })
    })  
    myPromisse.then((txt)=>{

    })    
}

function logout(){
    if(confirm(`Encerrar login de ${localStorage.getItem('email')}?`)){
        localStorage.clear()
        this.location.reload(true)    
    }
}

/* FRM BUSCA */

function getVal(fds){
    const doc = document.querySelector(`.${fds}`)
    const sel = doc.querySelector('#cmbBusca')
    const field = sel.value
    const signal = sel.options[sel.selectedIndex].getAttribute('signal')
    let value = sel.options[sel.selectedIndex].hasAttribute('val') ? sel.options[sel.selectedIndex].getAttribute('val') : doc.querySelector('#edtBusca').value.trim()
        value = signal=='LIKE' ? `'%${value}%'` : signal=='IN' ? `(${value})` : value

    return [field,signal,value]
}