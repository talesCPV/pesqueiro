
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

    doc.save('comanda_virtual.pdf')
}