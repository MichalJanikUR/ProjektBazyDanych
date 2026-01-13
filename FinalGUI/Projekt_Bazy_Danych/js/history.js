/**
 * Obsługa rozwijania i zwijania akordeonu treningu
 * @param {HTMLElement} header - Element nagłówka akordeonu
 */
function toggleAccordion(header) {
    // Przełączanie klasy aktywnej dla animacji strzałki
    header.classList.toggle('active');
    
    const content = header.nextElementSibling;
    
    // Prosta logika przełączania widoczności
    if (content.style.display === "block") {
        content.style.display = "none";
    } else {
        content.style.display = "block";
    }
}