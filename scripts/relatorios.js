
function comanda_virual(comanda){

    const logo = new Image()
    logo.src = 'assets/logo.png'


    const doc = new jsPDF({
        orientation: "portrait",
        unit: "mm",
        format: [550, 275]
    });


    doc.addImage(logo, 'png', 10, 10, logo.width/10, logo.height/10);

    doc.setFontSize(24);
    txt.y = logo.height/10 + 20
    doc.setFontSize(16);
    doc.text('Comanda Virtual',24,txt.y)
    addLine(3)
    line(txt.y)
    addLine()
    doc.text(`Cod.: ${comanda.id.padStart(5,0)}`,1,txt.y)
    addLine(2)
    doc.setFontSize(16);
    doc.text(`Data: ${comanda.data} ${comanda.hora}`,1,txt.y)
    addLine(2)
    doc.text(`Cliente: ${comanda.nome}`,1,txt.y)
    addLine(2)
    let base64Image = document.querySelector('#qr_code img').src
    doc.addImage(base64Image, 'png', 1, txt.y, 95, 95);
    txt.y += 95
    addLine()
    doc.setFontSize(12);
    doc.text(`Acompanhe sua comanda por este QR-Code`,6,txt.y)

    doc.save('comanda_virtual.pdf')
}