
function comanda_virual(comanda){

    const logo = new Image()
    logo.src = 'assets/logo.png'


    const doc = new jsPDF({
        orientation: "portrait",
        unit: "mm",
        format: [350, 200]
    });


    doc.addImage(logo, 'png', 10, 10, logo.width/14, logo.height/14);

    doc.setFontSize(10);
    txt.y = logo.height/14 + 20
    doc.text('Comanda Virtual',22,txt.y)
    addLine()
    line(txt.y)
    addLine()
    doc.text(`Comanda: ${comanda.id.padStart(5,0)}`,10,txt.y)
    addLine()
    doc.text(`Data: ${comanda.data} ${comanda.hora}`,10,txt.y)
    addLine()
    doc.text(`Cliente: ${comanda.nome}`,10,txt.y)
    addLine()
    let base64Image = document.querySelector('#qr_code img').src
    doc.addImage(base64Image, 'png', 10, txt.y, 50, 50);
    txt.y += 50
    addLine()
    doc.setFontSize(8);
    doc.text(`Acompanhe sua comanda por este QR-Code`,6,txt.y)

    doc.save('comanda_virtual.pdf')
}