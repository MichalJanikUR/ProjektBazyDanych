/**
 * Obsługa modala dodawania pomiarów - AwareFit
 */

function toggleMeasurementModal() {
    const modal = document.getElementById('measurementModal');
    modal.classList.toggle('active');
    
    // Blokada scrolla strony pod spodem
    if (modal.classList.contains('active')) {
        document.body.style.overflow = 'hidden';
    } else {
        document.body.style.overflow = 'auto';
    }
}

// Obsługa zdarzeń po załadowaniu DOM
document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('measurementModal');

    // Zamknij po kliknięciu w tło (overlay)
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            toggleMeasurementModal();
        }
    });

    // Zamknij klawiszem ESC
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && modal.classList.contains('active')) {
            toggleMeasurementModal();
        }
    });

    // Opcjonalna walidacja przed wysyłką
    const form = document.getElementById('measurementForm');
    form.addEventListener('submit', () => {
        const btn = form.querySelector('.modal-save-btn');
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> ZAPISYWANIE...';
        btn.style.opacity = '0.7';
        btn.style.pointerEvents = 'none';
    });
});