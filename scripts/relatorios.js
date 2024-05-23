
function comanda_virual(comanda){

    const logo = new Image()
    logo.src = 'assets/logo.png'


    const doc = new jsPDF({
        orientation: "portrait",
        unit: "mm",
        format: [550, 275]
    });


    doc.addImage(logo, 'png', 14, 10, logo.width/10, logo.height/10);

    doc.setFontSize(20);
    txt.y = logo.height/10 + 20
    doc.text('Comanda Virtual',22,txt.y)
    addLine(2)
    line(txt.y)
    addLine()
    doc.setFontSize(36);
    doc.text(comanda.id.padStart(5,0),30,txt.y)
    addLine(1.5)
    doc.setFontSize(18);
    doc.text(`${comanda.data} - ${comanda.hora}`,17,txt.y)
    addLine(3)
    doc.text(comanda.nome.toUpperCase(),1,txt.y)
    addLine(1)
    let base64Image = document.querySelector('#qr_code img').src
    doc.addImage(base64Image, 'png', 1, txt.y, 95, 95);
    txt.y += 95
    addLine()
    doc.setFontSize(12);
    doc.text(`Acompanhe sua comanda por este QR-Code`,6,txt.y)

    const pdf =  doc.output('dataurlstring').split(',')[1]
//    window.open(pdf, '_blank').focus()

//    var image = document.createElement('image');
    document.querySelector('#img').src = 'data:image/bmp;base64,'+pdf



    console.log(pdf)


}

function uploadFile(file){

    const up_data = new FormData();        
        up_data.append("sendFile",  file);

    const myRequest = new Request("backend/upFile.php",{
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


function cardapio(data){

    jsPDF.autoTableSetDefaults({
        headStyles: { fillColor: [37, 68, 65] },
    })

    const doc = new jsPDF() 

    const logo = new Image()
    logo.src = 'assets/logo.png'
    doc.addImage(logo, 'png', 5, 5, logo.width/15, logo.height/15);


    doc.setFontSize(30);
//    txt.y = logo.height/10 + 20
    txt.y = logo.height/15 +2
    doc.text('CARDÁPIO',85,txt.y)
    addLine(2)

    let title = ''
    const tables = []

    for(let i=0; i<data.length; i++){
        if(title != data[i].tipo){
            title = data[i].tipo
            const tbl = new Object
            tbl.head = [[{content: title, colSpan: 3, styles: {halign: 'center', fillColor: [22, 160, 133]}}]]
            tbl.body = []
            tables.push(tbl)
        }
        const row = [data[i].descricao,'R$'+data[i].preco]

        tables[tables.length-1].body.push(row)
    }


    for(let i=0; i<tables.length; i++){

        doc.autoTable({
            head: tables[i].head,
            body: tables[i].body,
    
            columnStyles: {
                0: {cellWidth: 50},
                1: {cellWidth: 10, hAling:'rigth' }
            },
            
            styles :{fontSize: 15},
            startY: txt.y
        });

        txt.y = doc.lastAutoTable.finalY + 15
    }

    doc.save('cardapio.pdf')
  
}