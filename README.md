# Amazon Orders Analysis: Profit Drivers & Growth Opportunities  
*A stakeholder executive narrative (FY-2019 – FY-2021)*  

---

## 1 | Executive Snapshot  

> **Why this matters**  
> Our 2019-21 customer and sales data show that profitability is heavily concentrated in a tiny “goldmine” cohort, while one-size-fits-all discounting and a narrow product mix erode margin headroom. Focusing on loyalists, smarter promotions, and category diversification can unlock **+3 – 5 pp contribution margin** without compromising the Amazon-level customer experience.

**Primary business goal** — Maximise sustainable contribution $ by lifting repeat-order revenue and safeguarding margin.

**At-a-glance metrics (FY-19-21)**


| **Focus area**          | **Insight**                                                                                     | **“So what?”**                                               |
|-------------------------|--------------------------------------------------------------------------------------------------|--------------------------------------------------------------|
| **High-value cohorts**  | 153 customers (4.2 %) generate **AU $9.35 m — 87 % of revenue**                                 | Retaining this micro-segment beats acquisition ROI every time |
| **Price sensitivity**   | Markdowns = 38 % of units but just 5 % of revenue; promo margin only AU $0.45 m vs AU $7.9 m full-price | Blanket sales cost ~4 pp of margin                           |
| **Assortment balance**  | House/Home & Kitchen = 86 % GMV @ 39.6 % margin; Food = 50.7 % margin but < 5 % share            | Over-reliance raises category risk & limits cross-sell       |
| **Customer behaviour**  | Repeat-order share hit 56.1 % in 2020; a goldmine customer averages **7.4 orders/yr**            | Confirms loyalty-led growth thesis; supports subscriptions   |
| **Geo performance**     | NSW + VIC + QLD = 84.5 % of revenue; SA delivers only 8.6 % on 4 % of customers                  | Targeted regional marketing can unlock under-indexed states  |
| **Seasonality**         | Revenue spiked +169 % in Nov-20 (peak day 22-Nov); margin cresting at 40.9 %                     | Capacity planning & surge pricing protect CX                |

---

## 2 | Method in Brief  

1. **Business case** — Profit uplift & loyalty expansion.  
2. **Re-calibrated KPIs** — Contribution $, Repeat-Order %, Promo ROI, Category Gross-Margin %, Regional Rev-Share.  
3. **Data curation** — Seven SQL Script (promo, tiering, margin, region, seasonality, …).  
4. **Prep & QA** — SQL CTEs for cohort tagging & spend buckets; row-count validation vs source files.  
5. **Analysis & viz** — Authored seven SQL scripts (appendix A) and produced for review. 
  
---

## 3 | Key Insights (STAR Framework)  

| **Situation / Task**                               | **Action**                                             | **Result**                                                                           |
|----------------------------------------------------|--------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| Revenue concentration — quantify spend tiers       | Classified 3,674 customers into four lifetime-GMV tiers| *Goldmine* (4.2 %) drives 87 % of revenue; long-tail < AU $100 contributes only 3.2 %                    |
| Promo dilution — assess 2020 sale impact           | Joined `ItemMarkupHistory.sale = TRUE` to 2020 orders  | Markdowns moved 37.7 % of units, just 5 % of revenue; margin drag **AU $1.3 m**                          |
| Assortment economics — link mix to margin          | Merged `ItemsInOrder` → `CategoryMarginTable`          | Food yields **50.7 % margin**; House/Home over-indexed at 86 % GMV                                       |
| Lifecycle health — measure new vs repeat           | Derived first-vs-repeat flags per month               | Repeat share 56.1 % (2020) — sticky CX but softening acquisition                                        |
| Regional footprint — expose white space            | Aggregated revenue by state                           | SA under-leveraged despite Adelaide DC                                                                  |
| Price-floor risk — find lowest mark-up             | CTE on `MIN(markup)`                                  | Five novelty SKUs at 1.1× cost set an unhealthy price anchor                                            |

---

## 4 | Recommendations  

| **What we’ll do**                                                                      | **Why**                                   | **Impact target**                                   |
|----------------------------------------------------------------------------------------|-------------------------------------------|-----------------------------------------------------|
| 1. **VIP-centric loyalty** — tiered perks, early drops, concierge chat                 | Deepen stickiness of goldmine cohort      | +5 pp repeat-order rate ⇒ **+AU $0.6 m** FY-26 margin|
| 2. **Promo optimisation engine** — elastic, customer-level offers; cap discounts ≥30 % | End one-size-fits-all markdowns           | **+AU $0.8 m** annual margin                        |
| 3. **Assortment diversification** — double Food & Novelty SKUs; launch “Home Basics”   | Lift blended margin & reduce category risk| +2 pp gross margin; House share < 75 %              |
| 4. **Regional growth pods** — SEM + influencers in SA/WA; 1-day delivery from Adelaide | Monetise under-indexed states             | +3 pp revenue share in 12 mo                        |
| 5. **Capacity & peak planning** — 3PL staff +20 % Oct-Dec; dynamic pick-pathing        | Protect CX during +169 % Nov surge        | SLA < 24 h dispatch at peak                         |
| 6. **Governance & monitoring** — live KPI scorecard; alerts ±2 s.d.                    | Build data-driven culture                 | Faster issue resolution; continuous optimisation    |

---

## 5 | Limitations & Next Steps  

* **Marketplace (3P) orders & returns** excluded — integrate for a 360° view.  
* **Promo file lacks coupon granularity** — capture going forward for sharper ROI attribution.  
* **Correlation ≠ causation** — run A/B tests on discount thresholds and assortment pilots.  

---

## 6 | Closing Take-away  

A tiny group of loyal customers, disciplined promotions, and a broader product mix are the levers that move our bottom line. Executing the six recommendations could lift contribution margin by **+3 – 5 pp** while maintaining the customer experience Amazon is famous for.

---

## Appendix A — SQL Script Summary  

1. **Spend-tier classification**   4. **Top-customer rank**  
2. **Category popularity**      5. **Order-distribution histogram**  
3. **Orders over time**       6. **2020 sale analysis**  
7. **SKU-level stock-out trend** *(planned)*  

--- 
> For questions or contributions, please open an issue or submit a pull request.
