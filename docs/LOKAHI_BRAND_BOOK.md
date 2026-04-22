# Lōkahi Therapeutics Brand Book

## Brand Overview

**Company Name**: Lōkahi Therapeutics  
**Tagline**: "Discover Innovative Therapies"  
**Industry**: Healthcare Technology / Clinical Therapeutics

### Mission Statement
"To drive clinical judgement, scientific rigor, and human empathy by integrating the power of actual intelligence with the dynamic evaluation of artificial intelligence."

### Brand Values
- **Clinical Excellence**: Prioritizing scientific rigor and medical accuracy
- **Human Empathy**: Balancing technology with compassionate care
- **Innovation**: Integrating AI with clinical expertise
- **Trust**: Building confidence through transparency and reliability

---

## Visual Identity

### Color Palette

#### Primary Colors
- **Dark Teal** `#234a67` - Primary brand color, conveys trust and professionalism
- **Deep Navy** `#113687` - Accent color, represents depth and expertise
- **Sky Blue** `#7abee1` - Secondary color, suggests innovation and clarity

#### Supporting Colors
- **Medium Teal** `#1c425b` - Used in gradients and overlays (rgba: 28, 66, 91)
- **Off-White** `#fdfcfa` - Background and light surfaces
- **Pure White** `#ffffff` - Clean surfaces and text on dark backgrounds
- **True Black** `#000000` - Text and strong emphasis

#### Color Usage Guidelines
- Use Dark Teal (#234a67) for primary UI elements, headers, and navigation
- Deep Navy (#113687) for accent elements, CTAs, and highlights
- Sky Blue (#7abee1) for interactive elements, links, and secondary actions
- Off-White (#fdfcfa) for backgrounds to reduce eye strain
- Maintain WCAG AA accessibility standards for all text/background combinations

### Typography

#### Primary Typeface
**Nunito Sans**
- A clean, modern, humanist sans-serif font
- Conveys approachability while maintaining professionalism
- Google Fonts: `https://fonts.googleapis.com/css2?family=Nunito+Sans:ital,wght@0,400;0,700;1,400;1,700`

#### Font Weights & Styles
- **Regular 400**: Body text, descriptions
- **Bold 700**: Headings, emphasis, navigation
- **Italic 400**: Subtle emphasis, citations
- **Bold Italic 700**: Strong emphasis (use sparingly)

#### Typography Scale
- **Headings**: Use bold weight (700)
- **Body Text**: Use regular weight (400)
- **Captions/Labels**: Use regular weight (400) with smaller size
- **Line Height**: 1.4-1.6 for optimal readability in medical context

---

## Design Language

### Core Principles

#### 1. Clinical Precision
- Clean layouts with clear hierarchy
- Generous white space
- Data-first presentation
- Minimal decoration

#### 2. Warm Professionalism
- Soft rounded corners (5px-10px border radius)
- Gentle transitions and animations
- Approachable color palette
- Human-centered interface elements

#### 3. Trust & Transparency
- Clear visual feedback
- Consistent interaction patterns
- Accessible design for all users
- No hidden or confusing elements

### Visual Elements

#### Border Radius
- **Small elements**: 5px (cards, inputs, buttons)
- **Medium elements**: 10px (modals, sections)
- **Large elements**: 6px (maps, images)
- **Circular**: 50vw for pill-shaped elements (newsletter, tags)

#### Shadows & Depth
- Subtle shadows for elevation
- Example: `box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3)`
- Use sparingly to create clear hierarchy

#### Spacing
- Consistent padding: 4vw for page margins
- Internal spacing: Use multiples of 8px (8, 16, 24, 32, etc.)
- Maintain breathing room around all interactive elements

#### Animations
- Duration: 0.3s - 0.4s for micro-interactions
- Easing: `ease-in-out` for smooth, natural motion
- Hover states: Subtle opacity changes (0.6) or slight scale (1.05)
- Avoid jarring or fast animations

---

## UI Components

### Buttons
- **Primary**: Solid background with brand colors
- **Secondary**: Outline style
- **Tertiary**: Text-only with underline on hover
- **Shape**: Pill-shaped (rounded)
- **Height**: Consistent at ~85% of container
- **Hover**: Opacity reduction or subtle shadow increase

### Forms
- **Fields**: Solid style with border-all
- **Shape**: Custom rounded corners
- **Checkboxes/Radio**: Icon-based, pill-shaped, outline style
- **Focus State**: Opacity-based feedback
- **Required Fields**: Asterisk (*) indicator

### Navigation
- **Style**: Clean with underline on active/hover
- **Animation**: Scale-x transition on hover (0.3s ease)
- **Folder Dropdowns**: Light blue background (#7abee1)
- **Border**: 1px bottom border for active states

### Cards & Lists
- **Border**: 1px solid in brand color (#234a67)
- **Border Radius**: 10px
- **Background**: Transparent or off-white
- **Hover**: Scale transform (1.05) with overlay
- **Transition**: 0.4s ease-in-out

---

## Content Guidelines

### Tone of Voice
- **Professional yet Accessible**: Use clear, jargon-free language when possible
- **Empathetic**: Acknowledge the human element in healthcare
- **Scientific**: Back claims with evidence and data
- **Optimistic**: Focus on solutions and positive outcomes

### Writing Style
- Use active voice
- Keep sentences concise
- Break complex information into digestible chunks
- Use headings and subheadings for scannability
- Include clear calls-to-action

### Medical Terminology
- Define technical terms on first use
- Provide context for clinical data
- Use patient-friendly explanations
- Include tooltips or glossary for complex terms

---

## Accessibility

### Standards
- Follow WCAG 2.1 Level AA guidelines
- Ensure color contrast ratios meet requirements
- Provide keyboard navigation for all interactive elements
- Include ARIA labels where appropriate

### Color Contrast
- Dark Teal (#234a67) on Off-White (#fdfcfa): ✓ Passes AA
- Deep Navy (#113687) on White (#ffffff): ✓ Passes AA
- Sky Blue (#7abee1) on Dark Teal (#234a67): ✓ Passes AA

### Interactive Elements
- Minimum touch target: 44x44px
- Clear focus indicators
- Sufficient spacing between clickable elements
- Visible hover states

---

## Application to GLP-1 Trial Weave App

### Brand Adaptation
While maintaining the core Lōkahi brand identity, the ai2 Trial Weave app should:

1. **Replace Oregon Green** (#007030) with **Dark Teal** (#234a67) as primary color
2. **Use Nunito Sans** instead of current typography
3. **Apply rounded corners** (5-10px) to all cards and UI elements
4. **Implement gentle animations** (0.3-0.4s transitions)
5. **Update color scheme**:
   - Primary actions: Deep Navy (#113687)
   - Secondary elements: Sky Blue (#7abee1)
   - Backgrounds: Off-White (#fdfcfa)
   - Text: True Black (#000000) or Dark Teal (#234a67)

### Visual Consistency
- Maintain clinical, data-focused design
- Apply Lōkahi's warm professionalism through softer corners and transitions
- Keep trustworthy aesthetic with new color palette
- Ensure all data visualizations use brand colors

---

## Implementation Checklist

### CSS/Tailwind Updates
- [ ] Update theme.css with new color variables
- [ ] Import Nunito Sans font
- [ ] Apply border-radius tokens
- [ ] Set transition timing functions
- [ ] Update button styles
- [ ] Modify form element styles

### Component Updates
- [ ] Update all primary color references
- [ ] Apply new font family
- [ ] Add transition properties
- [ ] Round sharp corners
- [ ] Update hover states

### Accessibility Review
- [ ] Test color contrast
- [ ] Verify keyboard navigation
- [ ] Check screen reader compatibility
- [ ] Validate focus indicators

---

## Resources

### Fonts
- Nunito Sans: https://fonts.google.com/specimen/Nunito+Sans
- Google Fonts CDN: `https://fonts.googleapis.com/css2?family=Nunito+Sans:ital,wght@0,400;0,700;1,400;1,700`

### Color Palette Reference
```css
--primary: #234a67;        /* Dark Teal */
--accent: #113687;         /* Deep Navy */
--secondary: #7abee1;      /* Sky Blue */
--background: #fdfcfa;     /* Off-White */
--overlay: #1c425b;        /* Medium Teal */
--text: #000000;           /* Black */
--white: #ffffff;          /* White */
```

### Border Radius Tokens
```css
--radius-sm: 5px;
--radius-md: 10px;
--radius-lg: 6px;
--radius-full: 50vw;
```

### Transition Tokens
```css
--transition-fast: 0.3s ease-in-out;
--transition-medium: 0.4s ease-in-out;
```

---

**Document Version**: 1.0  
**Last Updated**: April 11, 2026  
**Created By**: Brand Analysis of lokahithera.com
