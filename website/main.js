// ExpenseIQ - Landing Page Script

document.addEventListener('DOMContentLoaded', () => {
    // 1. Navbar Scroll Effect
    const nav = document.querySelector('nav');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            nav.style.top = '10px';
            nav.style.padding = '8px 20px';
            nav.style.boxShadow = '0 15px 35px rgba(0, 0, 0, 0.1)';
        } else {
            nav.style.top = '20px';
            nav.style.padding = '12px 24px';
            nav.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.05)';
        }
    });

    // 2. Reveal on Scroll Animation
    const revealElements = document.querySelectorAll('.feature-card, .hero-content, .hero-mockup, .download, .dev-card');
    
    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
                revealObserver.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.15,
        rootMargin: '0px 0px -50px 0px'
    });

    revealElements.forEach(el => {
        revealObserver.observe(el);
    });

    // 3. Smooth Anchors
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                const headerOffset = 100;
                const elementPosition = target.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });

    // 4. Download Buttons Feedback
    const downloadBtns = document.querySelectorAll('.download-btn, .btn-primary');
    downloadBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            // If the href is just "#", show a toast/alert
            if (btn.getAttribute('href') === '#' || btn.getAttribute('href') === '#download') {
                if (btn.classList.contains('download-btn')) {
                    e.preventDefault();
                    // Custom non-intrusive notification would be better, but console for now
                    // or just let the anchor scroll to #download
                    console.log('Download initiated...');
                }
            }
        });
    });
});

// Add dynamic animation class to CSS via JS if needed, but it's already in style.css
// However, I'll ensure the initial state is set correctly for the observer.
