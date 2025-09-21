# Impact of Interest Rate Shocks on Bank Stock Risk

**Author:** Ke Zhang  
**Audience:** Recruiters & Financial Industry Professionals  
**Last updated:** 2025-09-21

This repository accompanies a complete risk-analysis study of how **interest-rate shocks** affect the **risk of large U.S. bank equities**. It includes databuild notes, statistical methods, and backtests across Historical, EWMA, GARCH(1,1), **GJR‑GARCH**, and **EGARCH** models, with model validation via Kupiec (POF) and Christoffersen tests.

> **Executive takeaway:** Bank equity returns are **heavy‑tailed**, exhibit **persistent volatility**, and show **leverage (asymmetry)**. Among tested models, **GJR‑GARCH(1,1)** produced the most accurate 99% VaR coverage in backtests, while Gaussian/EWMA approaches tended to **underestimate tail risk**.

---

## 1) Project Overview

- **Goal:** Quantify how daily **interest‑rate shocks** (changes in U.S. 10‑Year Treasury yield) propagate into **bank stock risk** and portfolio VaR.  
- **Universe:** JPM, BAC, C, WFC (equal‑weighted portfolio also tested).  
- **Data:** Daily adjusted close prices (Yahoo Finance) and DGS10 yields (FRED).  
- **Horizon:** Core backtest window aligns with 2015–2024 (per final portfolio run).  
- **Key methods:** Return distribution diagnostics, **Historical VaR**, **Parametric (Normal) VaR**, **EWMA**, **GARCH(1,1)**, **GJR‑GARCH**, **EGARCH**, and **VaR backtesting** (Kupiec/Christoffersen).

---

## 2) Data Collection & Processing

- **Merging:** Prices/yields aligned on trading days; non‑trading days removed.  
- **Returns:** Stock log‑returns \( \ln(P_t/P_{t-1}) \); rate changes in **basis points**.  
- **Portfolio:** Equal‑weighted mix of JPM, BAC, C, WFC.  
- **Rationale:** Aligning equity returns with daily rate shocks isolates the interest‑rate channel while retaining market realism.

> **Insert (if available):** `figs/data_flow.png` – a simple diagram of the data pipeline.  
> Markdown placeholder: `![Data pipeline](figs/data_flow.png "Data and processing pipeline")`

---

## 3) Descriptive Statistics & Correlations

High **intra‑bank correlations** (≈0.8–0.9) indicate common industry/macro factors. Correlations with rate shocks are **positive but modest** (~0.28–0.34), implying rates matter yet do not dominate daily bank moves.

**Table 1. Correlation matrix (daily log‑returns vs. rate changes)**

|        | BAC   | C     | JPM   | WFC   | Rate (bps) |
|:------:|:-----:|:-----:|:-----:|:-----:|:----------:|
| **BAC**| 1.0000| 0.8738| 0.8921| 0.8319| 0.3446     |
| **C**  | 0.8738| 1.0000| 0.8624| 0.7973| 0.2783     |
| **JPM**| 0.8921| 0.8624| 1.0000| 0.8127| 0.3298     |
| **WFC**| 0.8319| 0.7973| 0.8127| 1.0000| 0.3015     |
| **Rate**|0.3446| 0.2783| 0.3298| 0.3015| 1.0000     |

> **Insert suggested plots:**  
> - `figs/price_panels.png` – price levels for each bank.  
> - `figs/corr_heatmap.png` – correlation heatmap.  
> - `figs/rate_changes.png` – daily DGS10 bp changes.  

---

## 4) Value‑at‑Risk (VaR) Analysis

Two 1‑day VaR approaches are compared at **95%** and **99%**:

- **Historical VaR:** empirical quantiles (5%/1%) of returns.  
- **Parametric (Normal) VaR:** \( \text{VaR}_\alpha = \mu + \sigma \,\Phi^{-1}(\alpha) \).

**Table 2. Historical vs. Parametric 1‑day VaR** *(loss thresholds, negatives)*

| Asset                | VaR 95% (Hist) | VaR 99% (Hist) | Mean (μ)  | σ      | VaR 95% (Norm) | VaR 99% (Norm) |
|---------------------|----------------:|---------------:|----------:|-------:|---------------:|---------------:|
| BAC                 | -0.029          | -0.054         | 0.000443  | 0.020  | -0.032         | -0.045         |
| C                   | -0.030          | -0.056         | 0.000211  | 0.021  | -0.034         | -0.048         |
| JPM                 | -0.026          | -0.046         | 0.000646  | 0.017  | -0.028         | -0.040         |
| WFC                 | -0.028          | -0.058         | 0.000215  | 0.020  | -0.032         | -0.046         |
| Interest Rate (bps) | -0.080          | -0.150         | 0.000985  | 0.054  | -0.088         | -0.125         |
| Portfolio (EW)      | -0.027          | -0.047         | –         | –      | -0.030         | -0.042         |

> **Insert suggested plots:**  
> - `figs/var_hist_vs_norm_BAC.png` – histogram + Normal overlay with 95/99% cutoffs.  
> - `figs/rolling_var_compare.png` – rolling Historical vs. Parametric VaR through time.

**Interpretation.** Historical VaR is **more conservative** than Gaussian VaR, consistent with **fat tails** in returns. Using Normal VaR can under‑capitalize during stress.

---

## 5) Return Distribution & Normality (H1)

**Jarque–Bera tests** decisively reject Normality. Excess kurtosis ~9–14 signals **heavy tails**.

**Table 3. Moments & JB test**

| Ticker | Mean  | σ      | Skewness | Excess Kurtosis | JB Statistic | JB p‑value |
|:-----:|------:|-------:|---------:|----------------:|-------------:|-----------:|
| BAC   | 0.0004| 0.0197 | -0.0175  | 9.5353          | 9417.31      | 0.0        |
| C     | 0.0002| 0.0207 | -0.4642  | 14.0810         | 20628.72     | 0.0        |
| JPM   | 0.0006| 0.0173 | -0.0254  | 13.3782         | 18540.26     | 0.0        |
| WFC   | 0.0002| 0.0199 | -0.2198  | 9.1837          | 8755.40      | 0.0        |

> **Insert suggested plots:**  
> - `figs/hist_qq_panels.png` – histograms + QQ‑plots for each stock.

---

## 6) Volatility Clustering (H2)

- **ACF of squared returns** shows persistent positive autocorrelation.  
- **Ljung–Box** on squared returns and **ARCH‑LM** tests: reject no‑ARCH (p≈0).  
- **SMA(21) & EWMA(λ=0.94)** capture time‑varying vol; late‑2022 spike aligns with rapid Fed hikes.

> **Insert suggested plots:**  
> - `figs/vol_ts_garch_vs_ewma.png` – conditional σ_t from GARCH vs. EWMA.  
> - `figs/acf_returns_vs_sq.png` – ACF of r_t and r_t^2 for a representative name.

**Table 4. GARCH(1,1) estimates & diagnostics (illustrative)**

| Ticker | μ       | ω        | α (ARCH) | β (GARCH) | α+β   | JB p | Ljung‑Box p | ARCH‑LM p |
|:-----:|:-------:|:--------:|:--------:|:---------:|:-----:|:----:|:-----------:|:---------:|
| BAC   | 0.000443| 0.000039 | 0.050000 | 0.900000  | 0.950 | 0.0  | 0.0         | 0.0       |
| C     | 0.000595| 0.000043 | 0.050881 | 0.898854  | 0.950 | 0.0  | 0.0         | 0.0       |
| JPM   | 0.000646| 0.000030 | 0.050000 | 0.900000  | 0.950 | 0.0  | 0.0         | 0.0       |
| WFC   | 0.000215| 0.000039 | 0.050000 | 0.900000  | 0.950 | 0.0  | 0.0         | 0.0       |

---

## 7) Asymmetric Volatility (H3)

We fit **GJR‑GARCH(1,1)** and **EGARCH(1,1)** to capture **leverage effects** (negative shocks → larger volatility).

**Table 5. Example parameter estimates (one bank)**

| Model            | μ      | ω       | α       | γ (leverage) | β     | LLF       |
|------------------|:------:|:-------:|:-------:|:------------:|:-----:|----------:|
| GARCH(1,1)       | 0.0004 | 0.0000  | 0.0500  | –            | 0.90  | 6370.3824 |
| GJR‑GARCH(1,1)   | 0.0004 | 0.0000  | 0.0500  | 0.0500       | 0.90  | 6538.6351 |
| EGARCH(1,1)      | 0.0006 | -0.3993 | 0.1694  | **-0.1094**  | 0.95  | **6620.4016** |

**Table 6. Model selection** *(lower is better)*

| Model          | AIC        | BIC        |
|----------------|-----------:|-----------:|
| GARCH(1,1)     | -12732.76  | -12709.47  |
| GJR‑GARCH(1,1) | -13067.27  | -13038.16  |
| EGARCH(1,1)    | **-13230.80** | **-13201.69** |

> **Insert suggested plot:** `figs/cond_vol_leverage.png` – conditional vol time series highlighting leverage periods.

**Interpretation.** EGARCH fits best by AIC/BIC and shows a **significantly negative γ**, confirming leverage. That said, **VaR coverage** still needs validation out‑of‑sample (next section).

---

## 8) VaR Backtesting & Validation (H4)

We compare 99% VaR violations over **2,497** out‑of‑sample days (expected ≈24).

**Table 7. VaR violations vs. expected (portfolio)**

| Model                         | Violations / N | Expected |
|-------------------------------|:--------------:|:--------:|
| Historical (250‑day window)   | 33 / 2248      | ~22      |
| EWMA (λ=0.94, parametric)     | **57 / 2497**  | ~24      |
| GARCH(1,1) (parametric)       | **11 / 2497**  | ~24      |
| GJR‑GARCH(1,1) (parametric)   | **21 / 2497**  | ~24      |
| EGARCH(1,1) (parametric)      | **40 / 2497**  | ~24      |

**Findings.**  
- **EWMA** and **EGARCH** **under‑estimate** tail risk (too many breaches).  
- **GARCH(1,1)** is **over‑conservative** (too few breaches).  
- **GJR‑GARCH(1,1)** achieves the **closest** unconditional/conditional coverage to 99% targets.

> **Insert suggested plots:**  
> - `figs/var_violations_timeline.png` – timeline of breaches.  
> - `figs/fed_events_overlay.png` – breach density around Fed announcements (event‑study).

---

## 9) Conclusions & Practical Implications

- **Heavy tails:** Gaussian VaR is optimistic; use historical or fat‑tailed/vol‑state models.  
- **Volatility persistence:** α+β≈0.95 → risk decays slowly; GARCH‑class models are essential.  
- **Leverage:** Negative shocks amplify volatility; models with asymmetry are preferred.  
- **Best VaR coverage here:** **GJR‑GARCH(1,1)** at 99% for the bank portfolio.

**For Risk Limits & Capital:** Prefer **GJR‑GARCH** (or t‑GARCH) over plain Gaussian or EWMA. Consider event overlays (Fed dates) to capture stress clustering.

---

## 10) References & Notes

- Kupiec, P. (1995). **Techniques for Verifying the Accuracy of Risk Measurement Models.**  
- Christoffersen, P. (1998). **Evaluating Interval Forecasts.**  
- McNeil, A. J., Frey, R., & Embrechts, P. (2015). **Quantitative Risk Management** (2nd ed.).  
- Data sources: Yahoo Finance (JPM, BAC, C, WFC); FRED (DGS10).  
- All tables/figures derive from the accompanying analysis code and outputs.

---

## 11) Repository Guide

```
├─ README.md                # You are here
├─ data/                    # (optional) CSVs: prices, yields, merged panel
├─ figs/                    # (optional) Export your plots here using the suggested names
├─ notebooks/               # (optional) Source notebooks / scripts
└─ src/                     # (optional) Functions for VaR, GARCH, backtests
```

> **Plot placement notes:** If you already have the figures, place them under `figs/` with the names listed above. The Markdown references in this README will render them automatically on GitHub.
