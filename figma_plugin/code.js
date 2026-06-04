// School Manager – Figma Mockup Generator
// Run this plugin inside Figma to generate the complete app mockup.

(async () => {
  // ─── Palette ────────────────────────────────────────────────────────────────
  const C = {
    bg1:       { r: 0.039, g: 0.055, b: 0.153 },  // #0A0E27
    bg2:       { r: 0.106, g: 0.133, b: 0.314 },  // #1B2250
    bg3:       { r: 0.063, g: 0.094, b: 0.235 },  // #101830
    primary:   { r: 0.263, g: 0.380, b: 0.933 },  // #4361EE
    primaryDk: { r: 0.212, g: 0.110, b: 0.867 },  // #361CB7
    cyan:      { r: 0.298, g: 0.788, b: 0.941 },  // #4CC9F0
    violet:    { r: 0.447, g: 0.035, b: 0.718 },  // #7209B7
    pink:      { r: 0.969, g: 0.145, b: 0.522 },  // #F72585
    success:   { r: 0.063, g: 0.725, b: 0.506 },  // #10B981
    warning:   { r: 0.957, g: 0.620, b: 0.145 },  // #F49D25
    error:     { r: 0.937, g: 0.267, b: 0.267 },  // #EF4444
    white:     { r: 1, g: 1, b: 1 },
    textPri:   { r: 0.94, g: 0.96, b: 1.0  },
    textSec:   { r: 0.65, g: 0.70, b: 0.88 },
    textHint:  { r: 0.40, g: 0.45, b: 0.62 },
    glass:     { r: 1, g: 1, b: 1, a: 0.08 },
    glassBdr:  { r: 1, g: 1, b: 1, a: 0.15 },
  };

  // ─── Load fonts ─────────────────────────────────────────────────────────────
  await Promise.all([
    figma.loadFontAsync({ family: "Inter", style: "Regular" }),
    figma.loadFontAsync({ family: "Inter", style: "Medium" }),
    figma.loadFontAsync({ family: "Inter", style: "Semi Bold" }),
    figma.loadFontAsync({ family: "Inter", style: "Bold" }),
    figma.loadFontAsync({ family: "Inter", style: "Extra Bold" }),
  ]);

  const W = 390, H = 844, GAP = 48;

  // ─── Low-level helpers ───────────────────────────────────────────────────────
  function rgb(c, a = 1) { return { type: "SOLID", color: { r: c.r, g: c.g, b: c.b }, opacity: a }; }

  function grad(stops) {
    return {
      type: "GRADIENT_LINEAR",
      gradientTransform: [[1, 0, 0], [0, 1, 0]],
      gradientStops: stops,
    };
  }

  function addRect(parent, x, y, w, h, color, alpha = 1, radius = 0) {
    const node = figma.createRectangle();
    node.x = x; node.y = y; node.resize(w, h);
    node.fills = [rgb(color, alpha)];
    node.cornerRadius = radius;
    parent.appendChild(node);
    return node;
  }

  function addText(parent, content, x, y, size, color, weight = "Regular", align = "LEFT", maxW = null) {
    const t = figma.createText();
    t.fontName = { family: "Inter", style: weight };
    t.characters = content;
    t.fontSize = size;
    t.fills = [rgb(color)];
    t.textAlignHorizontal = align;
    if (maxW) { t.textAutoResize = "HEIGHT"; t.resize(maxW, 40); }
    t.x = x; t.y = y;
    parent.appendChild(t);
    return t;
  }

  function addEllipse(parent, x, y, w, h, color, alpha = 1) {
    const e = figma.createEllipse();
    e.x = x; e.y = y; e.resize(w, h);
    e.fills = [rgb(color, alpha)];
    parent.appendChild(e);
    return e;
  }

  function addFrame(name, index) {
    const f = figma.createFrame();
    f.name = name;
    f.resize(W, H);
    f.x = index * (W + GAP);
    f.y = 0;
    f.fills = [{
      type: "GRADIENT_LINEAR",
      gradientTransform: [[0, 1, 0], [-1, 0, 1]],
      gradientStops: [
        { color: { ...C.bg1, a: 1 }, position: 0.0 },
        { color: { ...C.bg2, a: 1 }, position: 0.55 },
        { color: { ...C.bg3, a: 1 }, position: 1.0 },
      ],
    }];
    f.clipsContent = true;
    figma.currentPage.appendChild(f);
    return f;
  }

  function addGlassCard(parent, x, y, w, h, radius = 20, borderColor = null) {
    const card = figma.createRectangle();
    card.x = x; card.y = y; card.resize(w, h);
    card.cornerRadius = radius;
    card.fills = [rgb(C.white, 0.07)];
    card.strokes = [rgb(borderColor || C.white, 0.18)];
    card.strokeWeight = 1;
    card.effects = [{ type: "BACKGROUND_BLUR", radius: 12, visible: true }];
    parent.appendChild(card);
    return card;
  }

  function addGradBtn(parent, x, y, w, h, label, c1, c2, radius = 14) {
    const btn = figma.createRectangle();
    btn.x = x; btn.y = y; btn.resize(w, h);
    btn.cornerRadius = radius;
    btn.fills = [{
      type: "GRADIENT_LINEAR",
      gradientTransform: [[1, 0, 0], [0, 1, 0]],
      gradientStops: [
        { color: { ...c1, a: 1 }, position: 0 },
        { color: { ...c2, a: 1 }, position: 1 },
      ],
    }];
    btn.effects = [{ type: "DROP_SHADOW", color: { ...c1, a: 0.45 }, offset: { x: 0, y: 4 }, radius: 14, spread: 0, visible: true, blendMode: "NORMAL" }];
    parent.appendChild(btn);
    addText(parent, label, x, y + (h - 16) / 2, 15, C.white, "Bold", "CENTER", w);
    return btn;
  }

  function addAvatar(parent, x, y, size, letter, c1, c2) {
    const circle = figma.createEllipse();
    circle.x = x; circle.y = y; circle.resize(size, size);
    circle.fills = [{
      type: "GRADIENT_LINEAR",
      gradientTransform: [[1, 0, 0], [0, 1, 0]],
      gradientStops: [
        { color: { ...c1, a: 1 }, position: 0 },
        { color: { ...c2, a: 1 }, position: 1 },
      ],
    }];
    circle.effects = [{ type: "DROP_SHADOW", color: { ...c1, a: 0.4 }, offset: { x: 0, y: 4 }, radius: 12, spread: 0, visible: true, blendMode: "NORMAL" }];
    parent.appendChild(circle);
    if (letter) addText(parent, letter, x, y + (size - 18) / 2, 18, C.white, "Extra Bold", "CENTER", size);
    return circle;
  }

  function addBadge(parent, x, y, label, color, alpha = 0.18) {
    const bw = label.length * 7.5 + 20;
    const bg = figma.createRectangle();
    bg.x = x; bg.y = y; bg.resize(bw, 22);
    bg.cornerRadius = 11;
    bg.fills = [rgb(color, alpha)];
    bg.strokes = [rgb(color, 0.35)]; bg.strokeWeight = 1;
    parent.appendChild(bg);
    addText(parent, label, x, y + 3, 11, color, "Semi Bold", "CENTER", bw);
    return bg;
  }

  function addIconPlaceholder(parent, x, y, size, color) {
    const box = figma.createRectangle();
    box.x = x; box.y = y; box.resize(size, size);
    box.cornerRadius = size / 4;
    box.fills = [rgb(color, 0.18)];
    box.strokes = [rgb(color, 0.35)]; box.strokeWeight = 1;
    parent.appendChild(box);
    return box;
  }

  function addOrb(parent, x, y, size, color, alpha) {
    const orb = addEllipse(parent, x, y, size, size, color, alpha);
    orb.effects = [{ type: "LAYER_BLUR", radius: 60, visible: true }];
    return orb;
  }

  function addDivider(parent, x, y, w) {
    addRect(parent, x, y, w, 1, C.white, 0.08);
  }

  function addMenuCard(parent, x, y, w, title, subtitle, iconColor) {
    addGlassCard(parent, x, y, w, 70, 16);
    addIconPlaceholder(parent, x + 14, y + 15, 40, iconColor);
    addText(parent, title, x + 66, y + 14, 14, C.textPri, "Semi Bold", "LEFT", w - 80);
    addText(parent, subtitle, x + 66, y + 34, 11, C.textSec, "Regular", "LEFT", w - 80);
    // chevron
    const chev = figma.createRectangle();
    chev.x = x + w - 28; chev.y = y + 22; chev.resize(10, 26);
    chev.cornerRadius = 3; chev.fills = [rgb(C.white, 0.08)];
    parent.appendChild(chev);
  }

  function addStatCard(parent, x, y, w, h, value, label, color) {
    const card = figma.createRectangle();
    card.x = x; card.y = y; card.resize(w, h); card.cornerRadius = 18;
    card.fills = [{
      type: "GRADIENT_LINEAR",
      gradientTransform: [[1, 0, 0], [0, 1, 0]],
      gradientStops: [
        { color: { ...color, a: 0.22 }, position: 0 },
        { color: { ...color, a: 0.08 }, position: 1 },
      ],
    }];
    card.strokes = [rgb(color, 0.3)]; card.strokeWeight = 1;
    card.effects = [{ type: "BACKGROUND_BLUR", radius: 10, visible: true }];
    parent.appendChild(card);
    addText(parent, value, x, y + 18, 28, C.textPri, "Extra Bold", "CENTER", w);
    addText(parent, label, x, y + 54, 11, C.textSec, "Medium", "CENTER", w);
  }

  // ─── Screen 0 – Splash ───────────────────────────────────────────────────────
  function buildSplash(idx) {
    const f = addFrame("Splash Screen", idx);
    addOrb(f, -60, -60, 260, C.violet, 0.2);
    addOrb(f, 180, 600, 280, C.primary, 0.15);

    // Logo circle
    const logo = figma.createEllipse();
    logo.x = W/2 - 44; logo.y = 280; logo.resize(88, 88);
    logo.fills = [{
      type: "GRADIENT_LINEAR",
      gradientTransform: [[1, 0, 0], [0, 1, 0]],
      gradientStops: [
        { color: { ...C.primary, a: 1 }, position: 0 },
        { color: { ...C.violet, a: 1 }, position: 1 },
      ],
    }];
    logo.effects = [
      { type: "DROP_SHADOW", color: { ...C.primary, a: 0.55 }, offset: { x: 0, y: 8 }, radius: 28, spread: 0, visible: true, blendMode: "NORMAL" },
      { type: "DROP_SHADOW", color: { ...C.violet, a: 0.3 },  offset: { x: 0, y: 0 }, radius: 40, spread: 4, visible: true, blendMode: "NORMAL" },
    ];
    f.appendChild(logo);
    addText(f, "S", W/2 - 44, 307, 42, C.white, "Extra Bold", "CENTER", 88);

    addText(f, "School Manager", 0, 390, 24, C.textPri, "Bold", "CENTER", W);
    addText(f, "Plateforme scolaire intelligente", 0, 422, 13, C.textSec, "Regular", "CENTER", W);

    // Loading dots
    for (let i = 0; i < 3; i++) {
      const alpha = i === 1 ? 1 : 0.4;
      addEllipse(f, W/2 - 20 + i * 18, 740, 10, 10, C.primary, alpha);
    }
  }

  // ─── Screen 1 – Login ────────────────────────────────────────────────────────
  function buildLogin(idx) {
    const f = addFrame("Login Screen", idx);
    addOrb(f, W - 100, -80, 240, C.violet, 0.15);
    addOrb(f, -80, H - 100, 280, C.primary, 0.12);

    // Logo small
    const logo = figma.createEllipse();
    logo.x = W/2 - 28; logo.y = 72; logo.resize(56, 56);
    logo.fills = [{
      type: "GRADIENT_LINEAR",
      gradientTransform: [[1, 0, 0], [0, 1, 0]],
      gradientStops: [
        { color: { ...C.primary, a: 1 }, position: 0 },
        { color: { ...C.violet, a: 1 }, position: 1 },
      ],
    }];
    logo.effects = [{ type: "DROP_SHADOW", color: { ...C.primary, a: 0.5 }, offset: { x: 0, y: 6 }, radius: 20, spread: 0, visible: true, blendMode: "NORMAL" }];
    f.appendChild(logo);
    addText(f, "S", W/2 - 28, 88, 26, C.white, "Extra Bold", "CENTER", 56);

    addText(f, "Bon retour", 0, 145, 26, C.textPri, "Extra Bold", "CENTER", W);
    addText(f, "Connectez-vous à votre espace", 0, 178, 13, C.textSec, "Regular", "CENTER", W);

    // Glass card
    addGlassCard(f, 20, 214, W - 40, 310, 24);

    // Email field
    addRect(f, 36, 240, W - 72, 52, C.white, 0.06, 14);
    addText(f, "✉  Email professionnel", 52, 258, 13, C.textHint, "Regular", "LEFT", W - 100);

    // Password field
    addRect(f, 36, 308, W - 72, 52, C.white, 0.06, 14);
    addText(f, "🔒  Mot de passe", 52, 326, 13, C.textHint, "Regular", "LEFT", W - 100);

    addText(f, "Mot de passe oublié ?", W - 160, 374, 12, C.primary, "Medium", "RIGHT", 130);

    // CTA button
    addGradBtn(f, 36, 400, W - 72, 50, "Se connecter", C.primary, C.primaryDk, 14);

    // Role badges (decorative)
    const roles = [["Admin", C.pink], ["Professeur", C.primary], ["Étudiant", C.cyan]];
    let bx = (W - (roles.length * 98 + (roles.length-1)*8)) / 2;
    roles.forEach(([label, color]) => {
      addBadge(f, bx, 540, label, color);
      bx += 110;
    });
    addText(f, "Rôle détecté automatiquement", 0, 572, 11, C.textHint, "Regular", "CENTER", W);
  }

  // ─── Screen 2 – Admin Dashboard ──────────────────────────────────────────────
  function buildAdmin(idx) {
    const f = addFrame("Admin Dashboard", idx);
    addOrb(f, W - 100, -80, 240, C.pink, 0.14);
    addOrb(f, -80, H - 100, 280, C.primary, 0.10);

    // Header
    addText(f, "Bonjour,", 20, 52, 13, C.textSec, "Regular");
    addText(f, "Administrateur", 20, 70, 22, C.textPri, "Extra Bold");
    addBadge(f, 20, 100, "Espace Admin", C.pink);

    // Logout btn top-right
    const logBtn = figma.createRectangle();
    logBtn.x = W - 60; logBtn.y = 52; logBtn.resize(44, 44);
    logBtn.cornerRadius = 12; logBtn.fills = [rgb(C.error, 0.14)];
    logBtn.strokes = [rgb(C.error, 0.3)]; logBtn.strokeWeight = 1;
    f.appendChild(logBtn);

    // Stats 2x2
    const stats = [
      { v: "124", l: "Étudiants", c: C.primary },
      { v: "18",  l: "Professeurs", c: C.cyan },
      { v: "8",   l: "Classes", c: C.violet },
      { v: "12",  l: "Matières", c: C.pink },
    ];
    const sw = (W - 52) / 2;
    stats.forEach((s, i) => {
      const col = i % 2, row = Math.floor(i / 2);
      addStatCard(f, 20 + col * (sw + 12), 148 + row * (90 + 12), sw, 86, s.v, s.l, s.c);
    });

    // Menu title
    addText(f, "Gestion", 20, 360, 16, C.textPri, "Bold");

    const menuItems = [
      { title: "Gestion des utilisateurs", sub: "Ajouter, modifier, supprimer", color: C.primary },
      { title: "Gestion des classes",      sub: "Créer et organiser les classes", color: C.cyan },
      { title: "Gestion des matières",     sub: "Configurer le programme",        color: C.violet },
    ];
    menuItems.forEach((m, i) => {
      addMenuCard(f, 20, 388 + i * 82, W - 40, m.title, m.sub, m.color);
    });
  }

  // ─── Screen 3 – Professor Dashboard ─────────────────────────────────────────
  function buildProfessor(idx) {
    const f = addFrame("Professor Dashboard", idx);
    addOrb(f, W - 100, -80, 240, C.cyan, 0.14);
    addOrb(f, -80, H - 100, 280, C.primary, 0.10);

    // Header
    addText(f, "Bonjour,", 20, 52, 13, C.textSec, "Regular");
    addText(f, "Prof. Karim Ben Ali", 20, 70, 20, C.textPri, "Extra Bold");
    addBadge(f, 20, 100, "Espace Professeur", C.cyan);

    // Logout
    const logBtn = figma.createRectangle();
    logBtn.x = W - 60; logBtn.y = 52; logBtn.resize(44, 44);
    logBtn.cornerRadius = 12; logBtn.fills = [rgb(C.error, 0.14)];
    logBtn.strokes = [rgb(C.error, 0.3)]; logBtn.strokeWeight = 1;
    f.appendChild(logBtn);

    // Profile card
    addGlassCard(f, 20, 134, W - 40, 88, 22, C.cyan);
    addAvatar(f, 36, 150, 56, "K", C.primary, C.cyan);
    addText(f, "karim.benali@school.ma",  104, 152, 12, C.textSec, "Regular", "LEFT", W - 130);
    addText(f, "📘  Matière: Mathématiques", 104, 172, 11, C.cyan, "Semi Bold", "LEFT", W - 130);
    addText(f, "👥  Classes: 3A, 3B, 4A",   104, 190, 11, C.textSec, "Regular", "LEFT", W - 130);

    // Menu
    addText(f, "Menu", 20, 240, 16, C.textPri, "Bold");
    const menuItems = [
      { title: "Publier un devoir",        sub: "Assigner du travail à une classe",   color: C.primary },
      { title: "Mes devoirs publiés",      sub: "Gérer et suivre les devoirs",         color: C.violet },
      { title: "Affecter des notes",       sub: "Saisir les résultats des élèves",     color: C.cyan },
      { title: "Liste des étudiants",      sub: "Voir les profils et moyennes",        color: C.pink },
    ];
    menuItems.forEach((m, i) => {
      addMenuCard(f, 20, 268 + i * 82, W - 40, m.title, m.sub, m.color);
    });
  }

  // ─── Screen 4 – Student Dashboard ────────────────────────────────────────────
  function buildStudent(idx) {
    const f = addFrame("Student Dashboard", idx);
    addOrb(f, W - 100, -80, 240, C.violet, 0.14);
    addOrb(f, -80, H - 100, 280, C.primary, 0.10);

    addText(f, "Bonjour,", 20, 52, 13, C.textSec, "Regular");
    addText(f, "Amira Trabelsi", 20, 70, 20, C.textPri, "Extra Bold");
    addBadge(f, 20, 100, "Espace Étudiant", C.violet);

    // Logout
    const logBtn = figma.createRectangle();
    logBtn.x = W - 60; logBtn.y = 52; logBtn.resize(44, 44);
    logBtn.cornerRadius = 12; logBtn.fills = [rgb(C.error, 0.14)];
    logBtn.strokes = [rgb(C.error, 0.3)]; logBtn.strokeWeight = 1;
    f.appendChild(logBtn);

    // Profile card (violet tint)
    const profileCard = figma.createRectangle();
    profileCard.x = 20; profileCard.y = 134; profileCard.resize(W - 40, 88);
    profileCard.cornerRadius = 22;
    profileCard.fills = [{
      type: "GRADIENT_LINEAR",
      gradientTransform: [[1, 0, 0], [0, 1, 0]],
      gradientStops: [
        { color: { ...C.violet, a: 0.2 }, position: 0 },
        { color: { ...C.pink,   a: 0.1 }, position: 1 },
      ],
    }];
    profileCard.strokes = [rgb(C.violet, 0.3)]; profileCard.strokeWeight = 1;
    profileCard.effects = [{ type: "BACKGROUND_BLUR", radius: 12, visible: true }];
    f.appendChild(profileCard);

    addAvatar(f, 36, 150, 56, "A", C.violet, C.pink);
    addText(f, "amira.trabelsi@school.ma",    104, 152, 12, C.textSec, "Regular", "LEFT", W - 130);
    addText(f, "📚  Classe: Terminale Info A", 104, 172, 11, C.violet,  "Semi Bold", "LEFT", W - 130);

    addText(f, "Menu", 20, 240, 16, C.textPri, "Bold");
    const menuItems = [
      { title: "Mes devoirs",  sub: "Voir et marquer les devoirs comme faits", color: C.primary },
      { title: "Mes notes",    sub: "Consulter vos résultats et moyenne",      color: C.cyan },
      { title: "Déconnexion",  sub: "Quitter votre session",                   color: C.error },
    ];
    menuItems.forEach((m, i) => {
      addMenuCard(f, 20, 268 + i * 82, W - 40, m.title, m.sub, m.color);
    });
  }

  // ─── Screen 5 – Mes Devoirs (Student) ────────────────────────────────────────
  function buildHomework(idx) {
    const f = addFrame("Mes Devoirs", idx);
    addOrb(f, W - 100, -60, 200, C.primary, 0.12);

    // Back button + title
    const back = figma.createRectangle();
    back.x = 16; back.y = 16; back.resize(40, 40);
    back.cornerRadius = 12; back.fills = [rgb(C.white, 0.07)];
    back.strokes = [rgb(C.white, 0.15)]; back.strokeWeight = 1;
    f.appendChild(back);
    addText(f, "‹", 16, 20, 22, C.textPri, "Bold", "CENTER", 40);
    addText(f, "Mes devoirs", 68, 24, 18, C.textPri, "Bold");

    const homeworks = [
      { sub: "Mathématiques",  title: "Exercices d'algèbre linéaire", due: "16 Mai 2026", done: true  },
      { sub: "Physique",       title: "Rapport de TP – Optique",      due: "18 Mai 2026", done: false },
      { sub: "Informatique",   title: "TP Python – Algorithmes",      due: "20 Mai 2026", done: false },
      { sub: "Français",       title: "Dissertation – Littérature",   due: "22 Mai 2026", done: true  },
    ];

    homeworks.forEach((hw, i) => {
      const y = 76 + i * 98;
      addGlassCard(f, 16, y, W - 32, 86, 18);

      // Subject badge
      addBadge(f, 32, y + 12, hw.sub, C.primary);

      // Done / Pending badge
      const statusColor = hw.done ? C.success : C.warning;
      const statusLabel = hw.done ? "✓ Fait" : "En attente";
      addBadge(f, W - 80, y + 12, statusLabel, statusColor);

      addText(f, hw.title, 32, y + 42, 13, C.textPri, "Semi Bold", "LEFT", W - 64);
      addText(f, "📅 " + hw.due, 32, y + 62, 11, C.textSec, "Regular", "LEFT", 160);

      // Mark done button
      if (!hw.done) {
        const btnW = 72;
        const btn = figma.createRectangle();
        btn.x = W - btnW - 32; btn.y = y + 54; btn.resize(btnW, 28);
        btn.cornerRadius = 8; btn.fills = [rgb(C.primary, 0.2)];
        btn.strokes = [rgb(C.primary, 0.4)]; btn.strokeWeight = 1;
        f.appendChild(btn);
        addText(f, "Marquer ✓", W - btnW - 32, y + 60, 10, C.primary, "Semi Bold", "CENTER", btnW);
      }
    });
  }

  // ─── Screen 6 – Mes Notes (Student) ──────────────────────────────────────────
  function buildGrades(idx) {
    const f = addFrame("Mes Notes", idx);
    addOrb(f, W - 100, -60, 200, C.cyan, 0.12);

    const back = figma.createRectangle();
    back.x = 16; back.y = 16; back.resize(40, 40);
    back.cornerRadius = 12; back.fills = [rgb(C.white, 0.07)];
    back.strokes = [rgb(C.white, 0.15)]; back.strokeWeight = 1;
    f.appendChild(back);
    addText(f, "‹", 16, 20, 22, C.textPri, "Bold", "CENTER", 40);
    addText(f, "Mes notes", 68, 24, 18, C.textPri, "Bold");

    // Average card
    const avgCard = figma.createRectangle();
    avgCard.x = 16; avgCard.y = 72; avgCard.resize(W - 32, 90);
    avgCard.cornerRadius = 22;
    avgCard.fills = [{
      type: "GRADIENT_LINEAR",
      gradientTransform: [[1, 0, 0], [0, 1, 0]],
      gradientStops: [
        { color: { ...C.primary, a: 0.28 }, position: 0 },
        { color: { ...C.cyan,    a: 0.15 }, position: 1 },
      ],
    }];
    avgCard.strokes = [rgb(C.primary, 0.35)]; avgCard.strokeWeight = 1;
    avgCard.effects = [{ type: "BACKGROUND_BLUR", radius: 14, visible: true }];
    f.appendChild(avgCard);

    addText(f, "14.75", 16, 84, 36, C.textPri, "Extra Bold", "CENTER", W - 32);
    addText(f, "Moyenne Générale / 20", 16, 130, 12, C.textSec, "Regular", "CENTER", W - 32);

    // Grade rows
    const grades = [
      { sub: "Mathématiques",    g: 16.5, color: C.success },
      { sub: "Physique",         g: 13.0, color: C.warning },
      { sub: "Informatique",     g: 18.0, color: C.success },
      { sub: "Français",         g: 11.5, color: C.warning },
      { sub: "Anglais",          g:  9.5, color: C.error   },
    ];

    grades.forEach((gr, i) => {
      const y = 180 + i * 58;
      addGlassCard(f, 16, y, W - 32, 48, 14);
      addText(f, gr.sub, 32, y + 14, 13, C.textPri, "Semi Bold", "LEFT", W - 100);

      const badge = figma.createRectangle();
      badge.x = W - 80; badge.y = y + 10; badge.resize(56, 28);
      badge.cornerRadius = 8;
      badge.fills = [rgb(gr.color, 0.18)];
      badge.strokes = [rgb(gr.color, 0.35)]; badge.strokeWeight = 1;
      f.appendChild(badge);
      addText(f, `${gr.g}/20`, W - 80, y + 16, 12, gr.color, "Bold", "CENTER", 56);
    });
  }

  // ─── Screen 7 – Affecter Notes (Professor) ────────────────────────────────────
  function buildAddGrade(idx) {
    const f = addFrame("Affecter des Notes", idx);
    addOrb(f, W - 80, -60, 200, C.cyan, 0.14);

    const back = figma.createRectangle();
    back.x = 16; back.y = 16; back.resize(40, 40);
    back.cornerRadius = 12; back.fills = [rgb(C.white, 0.07)];
    back.strokes = [rgb(C.white, 0.15)]; back.strokeWeight = 1;
    f.appendChild(back);
    addText(f, "‹", 16, 20, 22, C.textPri, "Bold", "CENTER", 40);
    addText(f, "Affecter des notes", 68, 24, 18, C.textPri, "Bold");

    // Class dropdown
    addGlassCard(f, 16, 72, W - 32, 52, 14);
    addText(f, "🏫  Terminale Info A", 32, 88, 13, C.textPri, "Regular", "LEFT", W - 80);

    // Students list
    const students = [
      { name: "Amira Trabelsi",  avg: 14.75, color: C.success },
      { name: "Yassine Mejri",   avg: 11.20, color: C.warning },
      { name: "Nour Hamdi",      avg: 16.00, color: C.success },
      { name: "Mohamed Chihi",   avg:  8.50, color: C.error   },
    ];

    students.forEach((s, i) => {
      const y = 142 + i * 80;
      addGlassCard(f, 16, y, W - 32, 68, 16);
      addAvatar(f, 32, y + 14, 40, s.name[0], C.primary, C.cyan);
      addText(f, s.name, 84, y + 17, 13, C.textPri, "Semi Bold", "LEFT", W - 160);
      addText(f, `Moy: ${s.avg}/20`, 84, y + 37, 11, s.color, "Medium", "LEFT", 120);

      // + Note button
      const btnW = 64;
      const btn = figma.createRectangle();
      btn.x = W - btnW - 32; btn.y = y + 18; btn.resize(btnW, 32);
      btn.cornerRadius = 10;
      btn.fills = [{
        type: "GRADIENT_LINEAR",
        gradientTransform: [[1, 0, 0], [0, 1, 0]],
        gradientStops: [
          { color: { ...C.cyan, a: 1 }, position: 0 },
          { color: { ...C.primary, a: 1 }, position: 1 },
        ],
      }];
      btn.effects = [{ type: "DROP_SHADOW", color: { ...C.cyan, a: 0.35 }, offset: { x: 0, y: 3 }, radius: 8, spread: 0, visible: true, blendMode: "NORMAL" }];
      f.appendChild(btn);
      addText(f, "+ Note", W - btnW - 32, y + 24, 11, C.white, "Bold", "CENTER", btnW);
    });
  }

  // ─── Screen 8 – Add Homework (Professor) ─────────────────────────────────────
  function buildAddHomework(idx) {
    const f = addFrame("Publier un Devoir", idx);
    addOrb(f, W - 80, -60, 200, C.primary, 0.14);

    const back = figma.createRectangle();
    back.x = 16; back.y = 16; back.resize(40, 40);
    back.cornerRadius = 12; back.fills = [rgb(C.white, 0.07)];
    back.strokes = [rgb(C.white, 0.15)]; back.strokeWeight = 1;
    f.appendChild(back);
    addText(f, "‹", 16, 20, 22, C.textPri, "Bold", "CENTER", 40);
    addText(f, "Publier un devoir", 68, 24, 18, C.textPri, "Bold");

    const fields = [
      { label: "Titre du devoir",   hint: "Exercices d'algèbre – Chapitre 4" },
      { label: "Description",       hint: "Faire les exercices 1 à 5 du polycopié...", tall: true },
      { label: "Classe",            hint: "🏫  Terminale Info A" },
      { label: "Date limite",       hint: "📅  20 / 05 / 2026" },
    ];

    let y = 72;
    fields.forEach((field) => {
      addText(f, field.label, 16, y, 12, C.textSec, "Semi Bold");
      y += 22;
      const h = field.tall ? 88 : 52;
      addGlassCard(f, 16, y, W - 32, h, 14);
      addText(f, field.hint, 32, y + (h - 14) / 2, 13, C.textHint, "Regular", "LEFT", W - 64);
      y += h + 14;
    });

    // Publish button
    addGradBtn(f, 16, y + 8, W - 32, 52, "📤  Publier le devoir", C.primary, C.primaryDk, 16);
  }

  // ─── Build all screens ───────────────────────────────────────────────────────
  buildSplash(0);
  buildLogin(1);
  buildAdmin(2);
  buildProfessor(3);
  buildStudent(4);
  buildHomework(5);
  buildGrades(6);
  buildAddGrade(7);
  buildAddHomework(8);

  // Center viewport
  figma.viewport.scrollAndZoomIntoView(figma.currentPage.children);
  figma.closePlugin("✅ School Manager mockup généré — 9 écrans créés !");
})();
