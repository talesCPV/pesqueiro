
function backFunc(params,cod){
    const data = new URLSearchParams();        
        data.append("cod", cod);
        data.append("params", JSON.stringify(params));        

    const myRequest = new Request("backend/functions.php",{
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

function uploadImage(fileID,path,filename){

    const up_data = new FormData();        
        up_data.append("up_file",  document.getElementById(fileID).files[0]);
        up_data.append("path", path);
        up_data.append("filename", filename);

    const myRequest = new Request("backend/upload.php",{
        method : "POST",
        body : up_data
    });

    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());             
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 

    return myPromisse
}
