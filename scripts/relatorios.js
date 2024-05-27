
function comanda_virual(comanda){

    const logo = new Image()
    logo.src = 'assets/logo_peq.png'


    const doc = new jsPDF({
        orientation: "portrait",
        unit: "mm",
        format: [550, 275]
    });


    doc.addImage(logo, 'png', 24, 10, 50, 15.5);

    doc.setFontSize(20);
    txt.y = 35
    doc.text('Comanda Virtual',22,txt.y)
    addLine(2)
    line(txt.y)
    addLine()
    doc.setFontSize(36);
    doc.text(comanda.id.padStart(5,0),30,txt.y)
    addLine(2)
    doc.setFontSize(18);
    doc.text(`${comanda.data} - ${comanda.hora}`,17,txt.y)
    addLine(2)
    doc.setFontSize(12);
    doc.text(comanda.nome.toUpperCase(),5,txt.y)
    addLine(1)
    let base64Image = document.querySelector('#qr_code img').src
    doc.addImage(base64Image, 'png', 5, txt.y, 85, 85);
    txt.y += 85
    addLine()
    doc.setFontSize(12);
    doc.text(`Acompanhe sua comanda por este QR-Code`,5,txt.y)

    const blob = doc.output('blob')
    return uploadFile(blob,`config/user/${localStorage.getItem('id_user')}/temp/`,'comanda.pdf')
}

function cardapio_print(data){

    jsPDF.autoTableSetDefaults({
        headStyles: { fillColor: [37, 68, 65] },
    })

    const doc = new jsPDF() 

    const logo = new Image()
    logo.src = 'assets/logo.png'
    doc.addImage(logo, 'png', 15, 8, 40, 12,4);

    doc.setFontSize(30);
    txt.y = 18
    doc.text('CARDÁPIO',80,txt.y)
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
                0: {cellWidth: 60},
                1: {cellWidth: 10, haling:'rigth' }
            },
            
            styles :{fontSize: 15},
            startY: txt.y
        });
        txt.y = doc.lastAutoTable.finalY + 15
    }
    openPDF(doc,'cardapio')
}

function cardapio_pos(data){
    const logo = new Image()
    logo.src = 'assets/logo_peq.png'

    const doc = new jsPDF({
        orientation: "portrait",
        unit: "mm",
        format: [550, 275]
    });

    doc.addImage(logo, 'png', 22, 5, 50, 15.5);
    doc.setFontSize(20);
    txt.y = 28
    doc.setFontSize(10);
    let title = ''
    const tables = []

    for(let i=0; i<data.length; i++){
        
        if(title != data[i].tipo){
            title = data[i].tipo
            addLine(2)
            doc.setFontSize(16);
            doc.text(title,35,txt.y)
            addLine(2)
            doc.setFontSize(10);

        }

        doc.text(data[i].descricao,5,txt.y)
        doc.text(`R$${data[i].preco}`,80,txt.y)
        addLine(1)
        if(txt.y >= doc.internal.pageSize.getHeight() - 20){
            doc.addPage();
            txt.y=5
        }
    }
    openPDF(doc,'cardapio')
}

function produtos_pos(data){
    const logo = new Image()
    logo.src = 'assets/logo_peq.png'

    const doc = new jsPDF({
        orientation: "portrait",
        unit: "mm",
        format: [550, 275]
    });

    doc.addImage(logo, 'png', 22, 5, 50, 15.5);

    doc.setFontSize(30);
    txt.y = 22


    const tbl = new Object
    tbl.head = [['Descrição','Qtd']]
    tbl.body = []

    for(let i=0; i<data.length; i++){
        tbl.body.push([data[i].descricao,data[i].estoque])
    }

    doc.autoTable({
        head: tbl.head,
        body: tbl.body,
        columnStyles: {
            0: {cellWidth: 50},
            1: {cellWidth: 10, haling:'rigth' }
        },
        margin: {top: 10, right: 5, bottom: 0, left: 5},
        headStyles :{fillColor : [0], textColor : [255]},
        styles :{fontSize: 10, textColor : [0]},
        startY: txt.y
    });

    openPDF(doc,'produtos')

//    doc.save('cardapio.pdf')

}