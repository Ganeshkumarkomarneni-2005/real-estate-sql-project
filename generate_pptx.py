import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def create_deck():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6]

    # Theme colors
    NAVY = RGBColor(15, 23, 42)       # Slate 900
    DARK_CARD = RGBColor(30, 41, 59)  # Slate 800
    INDIGO = RGBColor(99, 102, 241)   # Accent indigo
    CYAN = RGBColor(6, 182, 212)      # Accent cyan
    EMERALD = RGBColor(16, 185, 129)  # Accent emerald
    AMBER = RGBColor(245, 158, 11)    # Accent amber
    WHITE = RGBColor(255, 255, 255)
    MUTED = RGBColor(148, 163, 184)   # Slate 400
    LIGHT_BG = RGBColor(248, 250, 252) # Slate 50
    TEXT_DARK = RGBColor(15, 23, 42)
    BORDER_COLOR = RGBColor(226, 232, 240)

    def add_header(slide, title_text, category="PROJECT 14: REAL ESTATE ANALYTICS"):
        # Header background banner
        header_shape = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(0), Inches(13.333), Inches(1.15))
        header_shape.fill.solid()
        header_shape.fill.fore_color.rgb = NAVY
        header_shape.line.fill.background()

        # Accent line under header
        line = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(1.15), Inches(13.333), Inches(0.06))
        line.fill.solid()
        line.fill.fore_color.rgb = INDIGO
        line.line.fill.background()

        # Category tracker
        cat_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.15), Inches(11.5), Inches(0.3))
        tf_cat = cat_box.text_frame
        tf_cat.word_wrap = True
        p_cat = tf_cat.paragraphs[0]
        p_cat.text = category.upper()
        p_cat.font.size = Pt(10)
        p_cat.font.bold = True
        p_cat.font.color.rgb = CYAN

        # Title
        title_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.42), Inches(11.5), Inches(0.6))
        tf = title_box.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = title_text
        p.font.size = Pt(22)
        p.font.bold = True
        p.font.color.rgb = WHITE

    def add_card(slide, left, top, width, height, bg_color=WHITE, border_color=BORDER_COLOR):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(left), Inches(top), Inches(width), Inches(height))
        card.fill.solid()
        card.fill.fore_color.rgb = bg_color
        card.line.color.rgb = border_color
        card.line.width = Pt(1)
        return card

    # =========================================================================
    # SLIDE 1: Title Slide
    # =========================================================================
    slide1 = prs.slides.add_slide(blank_layout)
    bg1 = slide1.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(0), Inches(13.333), Inches(7.5))
    bg1.fill.solid()
    bg1.fill.fore_color.rgb = NAVY
    bg1.line.fill.background()

    # Title box
    tb = slide1.shapes.add_textbox(Inches(1.0), Inches(1.5), Inches(11.333), Inches(3.0))
    tf = tb.text_frame
    tf.word_wrap = True
    
    p0 = tf.paragraphs[0]
    p0.text = "PROJECT 14 · REAL ESTATE BUSINESS INTELLIGENCE"
    p0.font.size = Pt(14)
    p0.font.bold = True
    p0.font.color.rgb = CYAN
    p0.space_after = Pt(14)

    p1 = tf.add_paragraph()
    p1.text = "Real Estate Property Pricing, Sales, and Rental Yield Analysis"
    p1.font.size = Pt(36)
    p1.font.bold = True
    p1.font.color.rgb = WHITE
    p1.space_after = Pt(14)

    p2 = tf.add_paragraph()
    p2.text = "Defensive SQL Analytics, Valuation Modeling, Data Governance & Market Reporting"
    p2.font.size = Pt(18)
    p2.font.color.rgb = MUTED
    p2.space_after = Pt(24)

    # Info strip cards
    cards_data = [
        ("Industry", "Real Estate Investment"),
        ("Database Engine", "MySQL 8.0+ Enterprise"),
        ("Scope", "Texas Metropolitan Hubs"),
        ("Final Deliverables", "Report, Dataset & SQL Scripts")
    ]
    for idx, (label, val) in enumerate(cards_data):
        c_left = 1.0 + idx * 2.85
        c = add_card(slide1, c_left, 5.0, 2.7, 1.4, bg_color=DARK_CARD, border_color=INDIGO)
        tb_c = slide1.shapes.add_textbox(Inches(c_left + 0.15), Inches(5.15), Inches(2.4), Inches(1.1))
        tf_c = tb_c.text_frame
        p_l = tf_c.paragraphs[0]
        p_l.text = label.upper()
        p_l.font.size = Pt(10)
        p_l.font.bold = True
        p_l.font.color.rgb = CYAN
        p_v = tf_c.add_paragraph()
        p_v.text = val
        p_v.font.size = Pt(13)
        p_v.font.bold = True
        p_v.font.color.rgb = WHITE

    # =========================================================================
    # SLIDE 2: Project Objectives & Core KPIs
    # =========================================================================
    slide2 = prs.slides.add_slide(blank_layout)
    add_header(slide2, "Project Objectives & Institutional KPIs")

    # Left card: Project Objectives
    add_card(slide2, 0.8, 1.45, 5.7, 5.5, bg_color=LIGHT_BG)
    tb_obj = slide2.shapes.add_textbox(Inches(1.0), Inches(1.65), Inches(5.3), Inches(5.1))
    tf_obj = tb_obj.text_frame
    tf_obj.word_wrap = True
    
    p = tf_obj.paragraphs[0]
    p.text = "Core Analytical Objectives"
    p.font.size = Pt(18)
    p.font.bold = True
    p.font.color.rgb = NAVY
    p.space_after = Pt(14)

    objs = [
        ("1. Pricing Patterns & Valuation:", "Identify price dispersion, price per sqft, and negotiation discounts across Austin, Dallas, Houston, and San Antonio."),
        ("2. Sales Velocity Tracking:", "Quantify inventory absorption speed using Days on Market (DOM) from initial listing to finalized sale."),
        ("3. Rental Cash Flow & Yield Performance:", "Audit recurring tenancy income, payment timeliness, and calculate annualized gross yields against purchase capital."),
        ("4. Regional Sub-Market Segmentation:", "Establish clear risk-return profiles: High Yield Cashflow Core vs. Ultra-Luxury Capital Appreciation."),
        ("5. Data Quality Defense:", "Trap and neutralize zero areas, extreme outliers, chronological inversions, duplicate listings, and join fan-out.")
    ]
    for title, desc in objs:
        p_t = tf_obj.add_paragraph()
        p_t.text = title
        p_t.font.bold = True
        p_t.font.size = Pt(13)
        p_t.font.color.rgb = INDIGO
        p_d = tf_obj.add_paragraph()
        p_d.text = desc
        p_d.font.size = Pt(11)
        p_d.font.color.rgb = TEXT_DARK
        p_d.space_after = Pt(8)

    # Right column: 5 Core KPIs cards
    kpis = [
        ("Median Sale Price", "$532,500", "Outlier-resistant benchmark across 16 closed transactions", AMBER),
        ("Price per Sq. Ft.", "$385 / sqft", "Filtered against non-positive and unrealistic (>50k) areas", INDIGO),
        ("Days on Market (DOM)", "64 Days", "Average liquidation speed from MLS listing to deed execution", CYAN),
        ("Calendar Occupancy Rate", "92.17%", "True 2023 tenancy clipped with GREATEST/LEAST dates", EMERALD),
        ("Gross Rental Yield", "5.82%", "Annualized gross rental income over property purchase price", INDIGO)
    ]
    for idx, (k_name, k_val, k_sub, k_col) in enumerate(kpis):
        k_top = 1.45 + idx * 1.08
        card = add_card(slide2, 6.8, k_top, 5.7, 0.98, bg_color=LIGHT_BG)
        tb_k = slide2.shapes.add_textbox(Inches(6.95), Inches(k_top + 0.08), Inches(5.4), Inches(0.85))
        tf_k = tb_k.text_frame
        p_k = tf_k.paragraphs[0]
        p_k.text = k_name.upper()
        p_k.font.size = Pt(10)
        p_k.font.bold = True
        p_k.font.color.rgb = MUTED
        
        p_v = tf_k.add_paragraph()
        p_v.text = f"{k_val}  —  "
        p_v.font.size = Pt(15)
        p_v.font.bold = True
        p_v.font.color.rgb = k_col
        
        run_sub = p_v.add_run()
        run_sub.text = k_sub
        run_sub.font.size = Pt(10)
        run_sub.font.bold = False
        run_sub.font.color.rgb = TEXT_DARK

    # =========================================================================
    # SLIDE 3: Problem Statement & Data Challenges
    # =========================================================================
    slide3 = prs.slides.add_slide(blank_layout)
    add_header(slide3, "Problem Statement: Real-World Data Challenges in Real Estate")

    challenges = [
        ("1. Zero & Negative Floor Area", "Data entry typos record properties with 0 sqft or negative values. Standard queries trigger fatal SQL Error 1365 (Division by zero) or negative unit values.", "Defense: NULLIF(area_sqft, 0) + WHERE area_sqft > 0"),
        ("2. Extreme Physical Outliers", "Mansion entered as 999,999 sqft instead of 9,999 sqft. An unvetted arithmetic mean distorts regional benchmark sqft by up to 400%, misleading acquisition models.", "Defense: Upper bound check area_sqft <= 50,000"),
        ("3. Chronological Date Inversions", "Transactions executed before listing date (e.g., -75 days) or lease termination preceding commencement date generate negative velocity/occupancy periods.", "Defense: DATEDIFF validation & chronological filtering"),
        ("4. Multi-Table Join Fan-Out", "Querying 1:N properties to listings to sales and leases to payments in a single flat join triggers Cartesian product explosions, multiplying revenue 3x to 10x.", "Defense: Decoupled CTE aggregation before outer joining"),
        ("5. Duplicate MLS Listings", "Brokerages submit multiple active listings for the same asset. Distorts active supply metrics, overstating market inventory and softening pricing power.", "Defense: Multi-attribute GROUP BY with HAVING COUNT > 1"),
        ("6. Orphaned Transactions & Payment Gaps", "Recorded deed transfers missing foreign keys to properties, plus chronic tenant delinquency masked by single-month snapshot reporting.", "Defense: LEFT JOIN orphan trapping & risk window CTEs")
    ]

    for idx, (title, problem, defense) in enumerate(challenges):
        col = idx % 2
        row = idx // 2
        c_left = 0.8 + col * 5.95
        c_top = 1.45 + row * 1.85
        add_card(slide3, c_left, c_top, 5.75, 1.7, bg_color=LIGHT_BG)
        tb_c = slide3.shapes.add_textbox(Inches(c_left + 0.15), Inches(c_top + 0.1), Inches(5.45), Inches(1.5))
        tf_c = tb_c.text_frame
        tf_c.word_wrap = True
        
        p = tf_c.paragraphs[0]
        p.text = title
        p.font.size = Pt(13)
        p.font.bold = True
        p.font.color.rgb = INDIGO
        p.space_after = Pt(4)

        p_pr = tf_c.add_paragraph()
        p_pr.text = f"Impact: {problem}"
        p_pr.font.size = Pt(10)
        p_pr.font.color.rgb = TEXT_DARK
        p_pr.space_after = Pt(3)

        p_df = tf_c.add_paragraph()
        p_df.text = f"✔ {defense}"
        p_df.font.size = Pt(10)
        p_df.font.bold = True
        p_df.font.color.rgb = EMERALD

    # =========================================================================
    # SLIDE 4: Relational Database Architecture (3NF Schema)
    # =========================================================================
    slide4 = prs.slides.add_slide(blank_layout)
    add_header(slide4, "Relational Schema Architecture: 6 Core Entities")

    schema_tables = [
        ("LOCATIONS", "7 Records", "Dimension: Sub-market regions, city, state, postal code, and urban classification.", ["location_id (PK)", "location_name", "city, state, postal_code", "region_type (Downtown/Suburban)"]),
        ("PROPERTIES", "30 Records", "Core Asset Registry: Bedrooms, baths, square footage, purchase price, and current status.", ["property_id (PK)", "location_id (FK)", "property_type, address", "area_sqft, purchase_price"]),
        ("PROPERTY_LISTINGS", "30 Records", "MLS Marketing Layer: Listing price, publication date, agent identity, and expiry date.", ["listing_id (PK)", "property_id (FK)", "listing_price, listing_date", "listing_status (Active/Sold)"]),
        ("SALES_TRANSACTIONS", "16 Records", "Capital Liquidation: Realized sale prices, sale execution dates, buyer names, and commissions.", ["transaction_id (PK)", "property_id (FK), listing_id (FK)", "sale_price, sale_date", "commission_amount"]),
        ("RENTAL_LEASES", "18 Records", "Tenancy Contracts: Tenant names, agreed monthly rents, lease start/end dates, and status.", ["lease_id (PK)", "property_id (FK)", "tenant_name, monthly_rent", "lease_start_date, lease_end_date"]),
        ("RENTAL_PAYMENTS", "48 Records", "Operating Cash Ledger: Monthly obligations, actual rent collected, due dates, and payment status.", ["payment_id (PK)", "lease_id (FK)", "due_date, payment_date", "rent_amount_paid, payment_status"])
    ]

    for idx, (t_name, t_cnt, t_desc, t_fields) in enumerate(schema_tables):
        col = idx % 3
        row = idx // 3
        c_left = 0.8 + col * 3.95
        c_top = 1.45 + row * 2.8
        add_card(slide4, c_left, c_top, 3.8, 2.65, bg_color=LIGHT_BG)
        tb_t = slide4.shapes.add_textbox(Inches(c_left + 0.15), Inches(c_top + 0.12), Inches(3.5), Inches(2.4))
        tf_t = tb_t.text_frame
        tf_t.word_wrap = True

        p = tf_t.paragraphs[0]
        p.text = t_name
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = INDIGO
        
        run_cnt = p.add_run()
        run_cnt.text = f"  [{t_cnt}]"
        run_cnt.font.size = Pt(11)
        run_cnt.font.color.rgb = CYAN
        p.space_after = Pt(4)

        p_d = tf_t.add_paragraph()
        p_d.text = t_desc
        p_d.font.size = Pt(10)
        p_d.font.color.rgb = TEXT_DARK
        p_d.space_after = Pt(6)

        for f in t_fields:
            p_f = tf_t.add_paragraph()
            p_f.text = f"• {f}"
            p_f.font.size = Pt(9.5)
            p_f.font.color.rgb = MUTED

    # =========================================================================
    # SLIDE 5: The 15 Responsibilities - Tasks 1 to 5
    # =========================================================================
    slide5 = prs.slides.add_slide(blank_layout)
    add_header(slide5, "The 15 Core Responsibilities: Tasks 1 to 5 (Asset Valuation & Velocity)")

    tasks_1_5 = [
        ("Task 1: Complete Asset Lifecycle Entity Mapping", "Relational Joins", "Unified multi-table INNER and cascading LEFT JOIN tracing physical properties from geographical location to active listings, executed sales, leases, and rent payments."),
        ("Task 2: Average & Median Sale Prices by Location", "Window Functions (ROW_NUMBER)", "Calculates mean and non-parametric exact median using ROW_NUMBER() and COUNT() window partitioning, preventing multi-million dollar luxury outliers from skewing sub-market benchmarks."),
        ("Task 3: Price per Square Foot ($/Sq.Ft.)", "Defensive Division (NULLIF)", "Standardizes unit property valuation with safe NULLIF(area_sqft, 0) and boundary filters (0 < area <= 50,000 sqft), automatically neutralizing zero and negative area anomalies."),
        ("Task 4: Property Pricing Across Asset Types", "Categorical Aggregation", "Compares average acquisition prices across Apartments ($432K), Condos ($520K), Single-Family Homes ($980K), and Luxury Villas ($2.82M), quantifying asset class risk premiums."),
        ("Task 5: Days on Market (DOM) Sales Velocity", "Date Calculations (DATEDIFF)", "Measures market absorption speed using DATEDIFF(sale_date, listing_date) with chronological guards (sale_date >= listing_date) to discard inverted records.")
    ]

    for idx, (t_title, t_tech, t_detail) in enumerate(tasks_1_5):
        c_top = 1.45 + idx * 1.12
        add_card(slide5, 0.8, c_top, 11.733, 1.02, bg_color=LIGHT_BG)
        tb_task = slide5.shapes.add_textbox(Inches(1.0), Inches(c_top + 0.08), Inches(11.3), Inches(0.85))
        tf_task = tb_task.text_frame
        tf_task.word_wrap = True
        
        p = tf_task.paragraphs[0]
        p.text = t_title
        p.font.size = Pt(13)
        p.font.bold = True
        p.font.color.rgb = NAVY
        
        run_tech = p.add_run()
        run_tech.text = f"  [{t_tech}]"
        run_tech.font.size = Pt(11)
        run_tech.font.color.rgb = INDIGO

        p_det = tf_task.add_paragraph()
        p_det.text = t_detail
        p_det.font.size = Pt(10.5)
        p_det.font.color.rgb = TEXT_DARK

    # =========================================================================
    # SLIDE 6: The 15 Responsibilities - Tasks 6 to 10
    # =========================================================================
    slide6 = prs.slides.add_slide(blank_layout)
    add_header(slide6, "The 15 Core Responsibilities: Tasks 6 to 10 (Inventory, Tenancy & Deduplication)")

    tasks_6_10 = [
        ("Task 6: Unsold Aging & Stale Listing Identification", "Conditional CASE Logic", "Flags unsold listings exceeding 90 and 180-day market thresholds. Trapped 7 stale listings (e.g., San Antonio 606 Long Unsold St at 437 days) needing pricing interventions."),
        ("Task 7: Monthly Rental Income Ledger & Collections", "Time-Series Aggregation", "Audits monthly rent due vs. collected vs. outstanding balance by property. Tracked $397,350 total collections in H1 2023 with an outstanding delinquent balance of $18,450."),
        ("Task 8: Gross Rental Yield with Denominator Audit", "Annualized Financial Yield", "Computes (Monthly Rent * 12 / Purchase Price) * 100 with defensive flags for missing or negative acquisition prices, preventing denominator-driven crashes."),
        ("Task 9: Calendar-Year Clipped Occupancy Rates", "Boundary Normalization (GREATEST/LEAST)", "Clips lease tenancies strictly to the 2023 calendar year (365 eligible rentable days) using LEAST(end_date, '2023-12-31') and GREATEST(start_date, '2023-01-01')."),
        ("Task 10: Duplicate MLS Listing Identification", "GROUP BY ... HAVING COUNT > 1", "Scans multiple listing submissions by grouping on property_id, price, and listing date. Trapped duplicate MLS listings #16 & #17 for Property #29, preserving inventory accuracy.")
    ]

    for idx, (t_title, t_tech, t_detail) in enumerate(tasks_6_10):
        c_top = 1.45 + idx * 1.12
        add_card(slide6, 0.8, c_top, 11.733, 1.02, bg_color=LIGHT_BG)
        tb_task = slide6.shapes.add_textbox(Inches(1.0), Inches(c_top + 0.08), Inches(11.3), Inches(0.85))
        tf_task = tb_task.text_frame
        tf_task.word_wrap = True
        
        p = tf_task.paragraphs[0]
        p.text = t_title
        p.font.size = Pt(13)
        p.font.bold = True
        p.font.color.rgb = NAVY
        
        run_tech = p.add_run()
        run_tech.text = f"  [{t_tech}]"
        run_tech.font.size = Pt(11)
        run_tech.font.color.rgb = CYAN

        p_det = tf_task.add_paragraph()
        p_det.text = t_detail
        p_det.font.size = Pt(10.5)
        p_det.font.color.rgb = TEXT_DARK

    # =========================================================================
    # SLIDE 7: The 15 Responsibilities - Tasks 11 to 15
    # =========================================================================
    slide7 = prs.slides.add_slide(blank_layout)
    add_header(slide7, "The 15 Core Responsibilities: Tasks 11 to 15 (Auditing & Executive Reporting)")

    tasks_11_15 = [
        ("Task 11: Missing Foreign Key Reference Detection", "Relational Anti-Join", "Identifies orphaned transactions lacking valid property foreign keys via LEFT JOIN ... WHERE p.property_id IS NULL. Successfully isolated orphaned transaction #16."),
        ("Task 12: Unified Multi-Table Anomaly Validation Suite", "Diagnostic UNION ALL", "Executes an enterprise diagnostic scan across all 6 tables flagging impossible areas, negative prices, and inverted dates into an actionable issue table."),
        ("Task 13: Asking Price vs. Realized Sale Price Variance", "Negotiation Analytics", "Quantifies broker discount spread: (Sale Price - Listing Price) / Listing Price * 100. Average Texas transaction closed at -3.4% below asking, with Austin condos commanding +2.1% premium."),
        ("Task 14: Rental Payment Gaps & Chronic Tenant Default", "Multi-Stage Delinquency CTE", "Separates isolated late payments from chronic delinquencies. Flagged Lease #9 (Property #11) with a 'High Risk / Chronic Delinquency' profile across 3 unpaid months."),
        ("Task 15: Master Location Performance Report (Anti-Fanout)", "Modular Decoupled CTEs", "Consolidates inventory, sales volume, median prices, collected rent, occupancy, and gross yield without Cartesian product distortion across 7 sub-markets.")
    ]

    for idx, (t_title, t_tech, t_detail) in enumerate(tasks_11_15):
        c_top = 1.45 + idx * 1.12
        add_card(slide7, 0.8, c_top, 11.733, 1.02, bg_color=LIGHT_BG)
        tb_task = slide7.shapes.add_textbox(Inches(1.0), Inches(c_top + 0.08), Inches(11.3), Inches(0.85))
        tf_task = tb_task.text_frame
        tf_task.word_wrap = True
        
        p = tf_task.paragraphs[0]
        p.text = t_title
        p.font.size = Pt(13)
        p.font.bold = True
        p.font.color.rgb = NAVY
        
        run_tech = p.add_run()
        run_tech.text = f"  [{t_tech}]"
        run_tech.font.size = Pt(11)
        run_tech.font.color.rgb = EMERALD

        p_det = tf_task.add_paragraph()
        p_det.text = t_detail
        p_det.font.size = Pt(10.5)
        p_det.font.color.rgb = TEXT_DARK

    # =========================================================================
    # SLIDE 8: Deliberate Data Quality Traps & Defense Audit
    # =========================================================================
    slide8 = prs.slides.add_slide(blank_layout)
    add_header(slide8, "Data Governance: 10 Deliberate Quality Traps Neutralized")

    # Left: chart image
    chart_path = "assets/images/chart_data_quality_issues.png"
    if os.path.exists(chart_path):
        slide8.shapes.add_picture(chart_path, Inches(0.8), Inches(1.45), width=Inches(5.5))

    # Right: Trap audit table
    add_card(slide8, 6.6, 1.45, 5.9, 5.5, bg_color=LIGHT_BG)
    tb_t = slide8.shapes.add_textbox(Inches(6.8), Inches(1.6), Inches(5.5), Inches(5.2))
    tf_t = tb_t.text_frame
    tf_t.word_wrap = True

    p = tf_t.paragraphs[0]
    p.text = "Audit Summary: 10 Quality Traps"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = NAVY
    p.space_after = Pt(10)

    traps = [
        ("Negative Floor Area (#21)", "-950 sqft -> Filtered by area_sqft > 0"),
        ("Zero Area Crash (#22)", "0.00 sqft -> Protected by NULLIF(area, 0)"),
        ("Extreme Area Outlier (#23)", "999,999 sqft -> Trapped by area <= 50,000"),
        ("Negative Purchase Price (#24)", "-$450,000 -> Excluded from yield by price > 0"),
        ("Missing Price (#11, #14)", "NULL price -> Flagged with audit annotations"),
        ("Inverted Sale Date (#28 / #15)", "Sale before listing -> Guarded by sale >= list"),
        ("Inverted Lease Term (#18)", "End < Start -> Filtered by end >= start"),
        ("Duplicate Listings (#16, #17)", "Prop #29 -> Deduplicated via HAVING COUNT > 1"),
        ("Orphaned Transaction (#16)", "NULL property_id -> Trapped by anti-join audit"),
        ("Chronic Delinquency (#11)", "Lease #9 -> Tagged via chronic offender CTE")
    ]
    for name, defense in traps:
        p_tr = tf_t.add_paragraph()
        p_tr.text = f"• {name}: "
        p_tr.font.bold = True
        p_tr.font.size = Pt(10)
        p_tr.font.color.rgb = INDIGO
        run_d = p_tr.add_run()
        run_d.text = defense
        run_d.font.bold = False
        run_d.font.color.rgb = TEXT_DARK
        p_tr.space_after = Pt(3)

    # =========================================================================
    # SLIDE 9: Market Valuation & Velocity Analytics
    # =========================================================================
    slide9 = prs.slides.add_slide(blank_layout)
    add_header(slide9, "Property Pricing Patterns & Sales Velocity")

    # Left: Sale price by city image
    c1 = "assets/images/chart_sale_price_by_city.png"
    if os.path.exists(c1):
        slide9.shapes.add_picture(c1, Inches(0.8), Inches(1.45), width=Inches(5.7))

    # Right: Price per sqft image
    c2 = "assets/images/chart_price_per_sqft.png"
    if os.path.exists(c2):
        slide9.shapes.add_picture(c2, Inches(6.8), Inches(1.45), width=Inches(5.7))

    # Bottom metric strip
    b_card = add_card(slide9, 0.8, 5.85, 11.733, 1.25, bg_color=DARK_CARD, border_color=INDIGO)
    tb_b = slide9.shapes.add_textbox(Inches(1.0), Inches(5.95), Inches(11.3), Inches(1.0))
    tf_b = tb_b.text_frame
    tf_b.word_wrap = True
    
    p = tf_b.paragraphs[0]
    p.text = "KEY VALUATION TAKEAWAYS"
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = CYAN
    p.space_after = Pt(3)

    p_body = tf_b.add_paragraph()
    p_body.text = "• Austin & Dallas Command Top Unit Pricing: Downtown Austin leads at $417/sq.ft. and Dallas Uptown at $406/sq.ft.\n• Median vs Mean Divergence: In luxury markets (Austin Westlake Hills & Houston Woodlands), arithmetic mean is distorted by mega-villas ($2.8M+); exact median provides the truer market clearing signal."
    p_body.font.size = Pt(10.5)
    p_body.font.color.rgb = WHITE

    # =========================================================================
    # SLIDE 10: Rental Cash Flow & Yield Performance
    # =========================================================================
    slide10 = prs.slides.add_slide(blank_layout)
    add_header(slide10, "Rental Cashflow, Tenancy Occupancy & Gross Yield")

    # Left: Gross rental yield image
    c3 = "assets/images/chart_gross_rental_yield.png"
    if os.path.exists(c3):
        slide10.shapes.add_picture(c3, Inches(0.8), Inches(1.45), width=Inches(5.7))

    # Right: Monthly income trend
    c4 = "assets/images/chart_rental_income_trend.png"
    if os.path.exists(c4):
        slide10.shapes.add_picture(c4, Inches(6.8), Inches(1.45), width=Inches(5.7))

    # Bottom metric strip
    b_card2 = add_card(slide10, 0.8, 5.85, 11.733, 1.25, bg_color=DARK_CARD, border_color=CYAN)
    tb_b2 = slide10.shapes.add_textbox(Inches(1.0), Inches(5.95), Inches(11.3), Inches(1.0))
    tf_b2 = tb_b2.text_frame
    tf_b2.word_wrap = True
    
    p = tf_b2.paragraphs[0]
    p.text = "KEY CASHFLOW TAKEAWAYS"
    p.font.size = Pt(11)
    p.font.bold = True
    p.font.color.rgb = EMERALD
    p.space_after = Pt(3)

    p_body = tf_b2.add_paragraph()
    p_body.text = "• Cashflow vs Appreciation Trade-off: San Antonio (7.41%) and Dallas Plano (7.15%) offer highest cashflow yields; Austin Westlake (4.12%) trades current yield for luxury capital appreciation.\n• Steady Tenancy Inflows: H1 2023 produced $397,350 across 10 active leases with 92.17% portfolio-wide occupancy."
    p_body.font.size = Pt(10.5)
    p_body.font.color.rgb = WHITE

    # =========================================================================
    # SLIDE 11: Executive Location Performance Scorecard
    # =========================================================================
    slide11 = prs.slides.add_slide(blank_layout)
    add_header(slide11, "Executive Market Performance Report (Task 15 / Phase 6)")

    # Scorecard Table
    rows = 8
    cols = 7
    left = Inches(0.8)
    top = Inches(1.45)
    width = Inches(11.733)
    height = Inches(4.5)

    table_shape = slide11.shapes.add_table(rows, cols, left, top, width, height)
    tbl = table_shape.table

    tbl_data = [
        ["City / Sub-Market", "Zone", "Sales", "Median Price", "Price/SqFt", "Occupancy", "Gross Yield"],
        ["Austin - Downtown Core", "Downtown", "3", "$435,000", "$417.39", "94.2%", "6.85% (High Yield)"],
        ["Austin - Westlake Hills", "Suburban", "2", "$2,125,000", "$508.93", "88.5%", "4.12% (Appreciation)"],
        ["Dallas - Uptown Arts", "Uptown", "3", "$590,000", "$406.25", "96.1%", "6.42% (Balanced Growth)"],
        ["Dallas - Plano Tech", "Suburban", "2", "$565,000", "$260.34", "91.8%", "7.15% (High Yield)"],
        ["Houston - Riverfront", "Waterfront", "2", "$357,500", "$365.38", "90.4%", "6.94% (High Yield)"],
        ["Houston - The Woodlands", "Suburban", "2", "$1,055,000", "$294.57", "95.0%", "5.38% (Balanced Growth)"],
        ["San Antonio - Pearl Dist", "Downtown", "2", "$435,000", "$283.33", "89.2%", "7.41% (High Yield)"]
    ]

    for r_idx, row_values in enumerate(tbl_data):
        for c_idx, cell_value in enumerate(row_values):
            cell = tbl.cell(r_idx, c_idx)
            cell.text = cell_value
            p = cell.text_frame.paragraphs[0]
            p.font.size = Pt(10.5)
            if r_idx == 0:
                p.font.bold = True
                p.font.color.rgb = WHITE
                cell.fill.solid()
                cell.fill.fore_color.rgb = NAVY
            else:
                p.font.color.rgb = TEXT_DARK
                cell.fill.solid()
                cell.fill.fore_color.rgb = WHITE if r_idx % 2 == 1 else LIGHT_BG

    # Bottom commentary box
    tb_c = slide11.shapes.add_textbox(Inches(0.8), Inches(6.15), Inches(11.733), Inches(0.95))
    tf_c = tb_c.text_frame
    p_com = tf_c.paragraphs[0]
    p_com.text = "STRATEGIC ASSET ALLOCATION GUIDANCE"
    p_com.font.size = Pt(11)
    p_com.font.bold = True
    p_com.font.color.rgb = INDIGO
    p_desc = tf_c.add_paragraph()
    p_desc.text = "• Core Cashflow Mandate: Allocate institutional capital toward San Antonio Pearl District and Dallas Plano for >7.0% net-yielding tenancy.\n• Capital Growth Mandate: Target Austin Westlake Hills for land-constrained appreciation, accepting lower initial gross yield in exchange for asset scarcity value."
    p_desc.font.size = Pt(10)
    p_desc.font.color.rgb = TEXT_DARK

    # =========================================================================
    # SLIDE 12: End Target of the Student (Learning Outcomes & Deliverables)
    # =========================================================================
    slide12 = prs.slides.add_slide(blank_layout)
    add_header(slide12, "End Target of the Student: Competencies & Final Deliverables")

    # Left: End Target Mandate
    add_card(slide12, 0.8, 1.45, 5.7, 5.5, bg_color=LIGHT_BG)
    tb_m = slide12.shapes.add_textbox(Inches(1.0), Inches(1.65), Inches(5.3), Inches(5.1))
    tf_m = tb_m.text_frame
    tf_m.word_wrap = True

    p = tf_m.paragraphs[0]
    p.text = "End Target Mandate Achieved"
    p.font.size = Pt(18)
    p.font.bold = True
    p.font.color.rgb = NAVY
    p.space_after = Pt(12)

    mandate_points = [
        ("1. Property Pricing & Rental Analysis", "Conducted exhaustive pricing distribution, days on market sales velocity, and gross yield evaluation across 30 properties."),
        ("2. Location-Based Metric Calculation", "Built parameterized location aggregates covering average/median prices, $/sqft, and calendar-clipped occupancy across 7 sub-markets."),
        ("3. Data Distortion Explanation", "Proved and documented how missing or dirty data (negative areas, non-positive acquisition prices, chronological inversions) severely corrupt financial modeling."),
        ("4. Anti-Fanout Architecture Mastery", "Engineered decoupled CTE pipelines eliminating Cartesian multiplication of sales revenue and rent cash flows in multi-table joins.")
    ]
    for m_t, m_d in mandate_points:
        p_t = tf_m.add_paragraph()
        p_t.text = m_t
        p_t.font.bold = True
        p_t.font.size = Pt(12)
        p_t.font.color.rgb = INDIGO
        p_d = tf_m.add_paragraph()
        p_d.text = m_d
        p_d.font.size = Pt(10.5)
        p_d.font.color.rgb = TEXT_DARK
        p_d.space_after = Pt(6)

    # Right: 3 Final Deliverables Cards
    deliverables = [
        ("Deliverable 1: Property Market Report", "Executive location scorecard (06_phase6_executive_market_report.sql) + Interactive single-page web dashboard (index.html) with 18 Chart.js visualizations.", INDIGO),
        ("Deliverable 2: Rental Yield Dataset", "Structured CSV outputs & query ledgers tracking monthly rent, collection efficiency, payment statuses, and annualized yields across all leased assets.", CYAN),
        ("Deliverable 3: Production SQL Scripts", "Complete, battle-tested 7-phase SQL repository (01_phase1 to 07_phase7) implementing window functions, defensive NULLIF division, and audit reconciliation.", EMERALD)
    ]
    for idx, (deliv_name, deliv_desc, deliv_col) in enumerate(deliverables):
        c_top = 1.45 + idx * 1.82
        add_card(slide12, 6.8, c_top, 5.733, 1.68, bg_color=LIGHT_BG)
        tb_d = slide12.shapes.add_textbox(Inches(7.0), Inches(c_top + 0.12), Inches(5.3), Inches(1.45))
        tf_d = tb_d.text_frame
        tf_d.word_wrap = True

        p = tf_d.paragraphs[0]
        p.text = deliv_name
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = deliv_col
        p.space_after = Pt(4)

        p_desc = tf_d.add_paragraph()
        p_desc.text = deliv_desc
        p_desc.font.size = Pt(11)
        p_desc.font.color.rgb = TEXT_DARK

    # =========================================================================
    # SLIDE 13: Interactive Dashboard & Cloud Deployment
    # =========================================================================
    slide13 = prs.slides.add_slide(blank_layout)
    add_header(slide13, "Live Deployment & Interactive Analytics Dashboard")

    # Left: Location performance chart
    c5 = "assets/images/chart_location_market_performance.png"
    if os.path.exists(c5):
        slide13.shapes.add_picture(c5, Inches(0.8), Inches(1.45), width=Inches(5.7))

    # Right card: Cloud Deployment details
    add_card(slide13, 6.8, 1.45, 5.733, 5.5, bg_color=LIGHT_BG)
    tb_dep = slide13.shapes.add_textbox(Inches(7.0), Inches(1.65), Inches(5.3), Inches(5.1))
    tf_dep = tb_dep.text_frame
    tf_dep.word_wrap = True

    p = tf_dep.paragraphs[0]
    p.text = "Live Cloud Interactive Dashboard"
    p.font.size = Pt(18)
    p.font.bold = True
    p.font.color.rgb = NAVY
    p.space_after = Pt(12)

    dep_bullets = [
        ("Live URL:", "https://ganeshkumarkomarneni-2005.github.io/real-estate-sql-project/"),
        ("Technology:", "Single-Page Application (SPA) powered by Chart.js 4.4 and semantic HTML5/CSS3."),
        ("Executive Glassmorphic UI:", "Modern dark theme with real-time responsive KPI counters, interactive bar charts, donut breakdowns, and location performance radar."),
        ("Offline Fail-Safe Renderer:", "Embedded Canvas 2D fallback engine guarantees zero-broken visuals even in offline or air-gapped investment environments."),
        ("GitHub Repository:", "https://github.com/Ganeshkumarkomarneni-2005/real-estate-sql-project.git")
    ]
    for lbl, val in dep_bullets:
        p_l = tf_dep.add_paragraph()
        p_l.text = lbl
        p_l.font.bold = True
        p_l.font.size = Pt(11.5)
        p_l.font.color.rgb = INDIGO
        p_v = tf_dep.add_paragraph()
        p_v.text = val
        p_v.font.size = Pt(10)
        p_v.font.color.rgb = TEXT_DARK
        p_v.space_after = Pt(6)

    # =========================================================================
    # SLIDE 14: Future Scope & Strategic Roadmap
    # =========================================================================
    slide14 = prs.slides.add_slide(blank_layout)
    add_header(slide14, "Future Scope: Advanced Analytics & Engineering Roadmap")

    phases = [
        ("Phase 1: Automated Ingestion (dbt & Airflow)", "Deploy dbt schema testing (not_null, unique, accepted_values) and automated orchestrations to enforce data quality contracts before warehouse landing.", INDIGO),
        ("Phase 2: Predictive Hedonic Valuation (AI/ML)", "Train XGBoost / LightGBM gradient boosting regressors on property characteristics (sqft, bedrooms, age, amenities) to predict fair market valuation spreads.", CYAN),
        ("Phase 3: Net Operating Income & Cap Rate", "Expand financial modeling from gross yields to Net Operating Income (NOI) by incorporating operating expenses, property taxes, insurance, HOA fees, and maintenance reserves.", EMERALD),
        ("Phase 4: Geospatial GIS Analytics (PostGIS)", "Migrate spatial coordinates to PostGIS to evaluate price premiums against school district ratings, transit access, and corporate tech corridor distances.", AMBER)
    ]
    for idx, (p_title, p_desc, p_col) in enumerate(phases):
        c_top = 1.45 + idx * 1.35
        add_card(slide14, 0.8, c_top, 11.733, 1.2, bg_color=LIGHT_BG)
        tb_p = slide14.shapes.add_textbox(Inches(1.0), Inches(c_top + 0.1), Inches(11.3), Inches(1.0))
        tf_p = tb_p.text_frame
        tf_p.word_wrap = True

        p = tf_p.paragraphs[0]
        p.text = p_title
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = p_col
        p.space_after = Pt(3)

        p_desc_el = tf_p.add_paragraph()
        p_desc_el.text = p_desc
        p_desc_el.font.size = Pt(11)
        p_desc_el.font.color.rgb = TEXT_DARK

    # =========================================================================
    # SLIDE 15: Conclusion & Summary
    # =========================================================================
    slide15 = prs.slides.add_slide(blank_layout)
    bg15 = slide15.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(0), Inches(13.333), Inches(7.5))
    bg15.fill.solid()
    bg15.fill.fore_color.rgb = NAVY
    bg15.line.fill.background()

    tb_end = slide15.shapes.add_textbox(Inches(1.0), Inches(1.5), Inches(11.333), Inches(4.5))
    tf_end = tb_end.text_frame
    tf_end.word_wrap = True

    p = tf_end.paragraphs[0]
    p.text = "CONCLUSION & VERIFICATION SUMMARY"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = CYAN
    p.space_after = Pt(14)

    p1 = tf_end.add_paragraph()
    p1.text = "Data Integrity is the Bedrock of Real Estate Investment"
    p1.font.size = Pt(32)
    p1.font.bold = True
    p1.font.color.rgb = WHITE
    p1.space_after = Pt(16)

    p2 = tf_end.add_paragraph()
    p2.text = "• All 15 Core Responsibilities Implemented & Audited\n• 10 Deliberate Data Quality Traps Trapped & Neutralized\n• 3 Core Deliverables Provided: Market Report, Rental Yield Dataset & Production SQL Suite\n• Live Deployment: https://ganeshkumarkomarneni-2005.github.io/real-estate-sql-project/"
    p2.font.size = Pt(16)
    p2.font.color.rgb = MUTED
    p2.space_after = Pt(24)

    p3 = tf_end.add_paragraph()
    p3.text = "Ganesh Kumar Komarneni · Real Estate SQL Analytics Project 14"
    p3.font.size = Pt(14)
    p3.font.bold = True
    p3.font.color.rgb = EMERALD

    output_path = "Real_Estate_Market_Analysis_Presentation.pptx"
    prs.save(output_path)
    print(f"Presentation saved successfully to: {os.path.abspath(output_path)}")

if __name__ == "__main__":
    create_deck()
