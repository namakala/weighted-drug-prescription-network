

# Getting started

Most of the works in this repository, especially the `R` scripts, should
be directly reproducible. You’ll need
[`git`](https://git-scm.com/downloads),
[`R`](https://www.r-project.org/),
[`quarto`](https://quarto.org/docs/download/), and more conveniently
[RStudio IDE](https://posit.co/downloads/) installed and running well in
your system. You simply need to fork/clone this repository using RStudio
by following [this tutorial, start right away from
`Step 2`](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2).
Using terminal in linux/MacOS, you can issue the following command:

``` bash
quarto tools install tinytex
```

This command will install `tinytex` in your path, which is required to
compile quarto documents as latex/pdf. Afterwards, in your RStudio
command line, you can copy paste the following code to setup your
working directory:

``` r
install.packages("renv") # Only need to run this step if `renv` is not installed
```

This step will install `renv` package, which will help you set up the
`R` environment. Please note that `renv` helps tracking, versioning, and
updating packages I used throughout the analysis.

``` r
renv::restore()
```

This step will read `renv.lock` file and install required packages to
your local machine. When all packages loaded properly (make sure there’s
no error at all), you *have to* restart your R session. At this point,
you need to export the data as `data.csv` and place it within the
`data/raw` directory. The directory structure *must* look like this:

``` bash
data
├── ...
├── raw
│   └── data.csv
└── ...
```

Then, you should be able to proceed with:

``` r
targets::tar_make()
```

This step will read `_targets.R` file, where I systematically draft all
of the analysis steps. Once it’s done running, you will find the
rendered document (either in `html` or `pdf`) inside the `draft`
directory.

# What’s this all about?

This is the functional pipeline for conducting statistical analysis. The
complete flow can be viewed in the following `mermaid` diagram:

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    xf1522833a4d242c5([""Up to date""]):::uptodate --- xb6630624a7b3aa0f([""Dispatched""]):::dispatched
    xb6630624a7b3aa0f([""Dispatched""]):::dispatched --- xd03d7c7dd2ddda2b([""Stem""]):::none
    xd03d7c7dd2ddda2b([""Stem""]):::none --- x6f7e04ea3427f824[""Pattern""]:::none
    x6f7e04ea3427f824[""Pattern""]:::none --- xeb2d7cac8a1ce544>""Function""]:::none
    xeb2d7cac8a1ce544>""Function""]:::none --- xbecb13963f49e50b{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    x9dba3c22e1d21a62>"weightEntry"]:::uptodate --> xfca58ef1ca4d3988>"pairByRow"]:::uptodate
    xfca58ef1ca4d3988>"pairByRow"]:::uptodate --> xc59b8dc8b2b9537a>"mkMatrix"]:::uptodate
    x26c10e8301abe4cc>"getNeuroMeds"]:::uptodate --> xe508889c070a8d9e>"genLabel"]:::uptodate
    x68782ecc3533f726{{"method"}}:::uptodate --> x024b56b2351401aa>"describeWeight"]:::uptodate
    x68782ecc3533f726{{"method"}}:::uptodate --> x6010feb1c812a9f7>"getWeightICC"]:::uptodate
    x68782ecc3533f726{{"method"}}:::uptodate --> x8e3ad4805a2a7067>"summarizeWeight"]:::uptodate
    xe508889c070a8d9e>"genLabel"]:::uptodate --> xc59b8dc8b2b9537a>"mkMatrix"]:::uptodate
    xb5bd0fc16144df35>"pivotMetrics"]:::uptodate --> x024b56b2351401aa>"describeWeight"]:::uptodate
    xb5bd0fc16144df35>"pivotMetrics"]:::uptodate --> x6010feb1c812a9f7>"getWeightICC"]:::uptodate
    xb5bd0fc16144df35>"pivotMetrics"]:::uptodate --> x8e3ad4805a2a7067>"summarizeWeight"]:::uptodate
    xc59b8dc8b2b9537a>"mkMatrix"]:::uptodate --> xc771947fa5a6f28e>"mkGraph"]:::uptodate
    x54d574d129b09fbf{{"type"}}:::uptodate --> x8e3ad4805a2a7067>"summarizeWeight"]:::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> xc5d78d328f7a6fee["raw_metrics_inv_log_multiplicative<br>inv_log multiplicative"]:::uptodate
    xf20669808bbd122d["graph_inv_log_multiplicative<br>inv_log multiplicative"]:::uptodate --> xc5d78d328f7a6fee["raw_metrics_inv_log_multiplicative<br>inv_log multiplicative"]:::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> xd5845efd825040d8["tbls"]:::uptodate
    x18b26034ab3a95e2>"readData"]:::uptodate --> xd5845efd825040d8["tbls"]:::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> x7f51f65db61b1f99(["metrics_inv_log_additive<br>inv_log additive"]):::uptodate
    x7204cf7a08011ab5(["list_metrics_inv_log_additive<br>inv_log additive"]):::uptodate --> x7f51f65db61b1f99(["metrics_inv_log_additive<br>inv_log additive"]):::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> x20b48fd38d63a83c["raw_metrics_base_multiplicative<br>base multiplicative"]:::uptodate
    x57f78ac45da0a0a0["graph_base_multiplicative<br>base multiplicative"]:::uptodate --> x20b48fd38d63a83c["raw_metrics_base_multiplicative<br>base multiplicative"]:::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> xbcf85a7029a82251(["list_metrics_product_multiplicative<br>product multiplicative"]):::uptodate
    x2dc8e27faf7c5664["raw_metrics_product_multiplicative<br>product multiplicative"]:::uptodate --> xbcf85a7029a82251(["list_metrics_product_multiplicative<br>product multiplicative"]):::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> x1496749256f55ed5["graph_base_additive<br>base additive"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> x1496749256f55ed5["graph_base_additive<br>base additive"]:::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> x4187040dac44a5dd(["list_metrics_product_additive<br>product additive"]):::uptodate
    xae2b4d2c9af9c3c7["raw_metrics_product_additive<br>product additive"]:::uptodate --> x4187040dac44a5dd(["list_metrics_product_additive<br>product additive"]):::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> x2b659433eb98f15a(["list_metrics_log_multiplicative<br>log multiplicative"]):::uptodate
    x31d7c7721d27b75d["raw_metrics_log_multiplicative<br>log multiplicative"]:::uptodate --> x2b659433eb98f15a(["list_metrics_log_multiplicative<br>log multiplicative"]):::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> x47b488cb93e9530b["raw_metrics_resultant_multiplicative<br>resultant multiplicative"]:::uptodate
    x02090f5acddb162e["graph_resultant_multiplicative<br>resultant multiplicative"]:::uptodate --> x47b488cb93e9530b["raw_metrics_resultant_multiplicative<br>resultant multiplicative"]:::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> x7204cf7a08011ab5(["list_metrics_inv_log_additive<br>inv_log additive"]):::uptodate
    xb7984997b0b65deb["raw_metrics_inv_log_additive<br>inv_log additive"]:::uptodate --> x7204cf7a08011ab5(["list_metrics_inv_log_additive<br>inv_log additive"]):::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> x23c100bf125a9529(["metrics_resultant_multiplicative<br>resultant multiplicative"]):::uptodate
    x487cbf8b9ca9e729(["list_metrics_resultant_multiplicative<br>resultant multiplicative"]):::uptodate --> x23c100bf125a9529(["metrics_resultant_multiplicative<br>resultant multiplicative"]):::uptodate
    x024b56b2351401aa>"describeWeight"]:::uptodate --> x88ae545a2aa85a8a(["metrics_desc"]):::uptodate
    x544e14c8fac2c5b0(["metrics"]):::uptodate --> x88ae545a2aa85a8a(["metrics_desc"]):::uptodate
    x6010feb1c812a9f7>"getWeightICC"]:::uptodate --> xe5f8941d25af7395(["metrics_icc"]):::uptodate
    x544e14c8fac2c5b0(["metrics"]):::uptodate --> xe5f8941d25af7395(["metrics_icc"]):::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> xcfb2d306ba24a904(["metrics_quotient_multiplicative<br>quotient multiplicative"]):::uptodate
    xfd6ca79b1f175a3f(["list_metrics_quotient_multiplicative<br>quotient multiplicative"]):::uptodate --> xcfb2d306ba24a904(["metrics_quotient_multiplicative<br>quotient multiplicative"]):::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> xa48e1a19ce1dd4c8(["list_metrics_quotient_additive<br>quotient additive"]):::uptodate
    xabccbe5cf0b36246["raw_metrics_quotient_additive<br>quotient additive"]:::uptodate --> xa48e1a19ce1dd4c8(["list_metrics_quotient_additive<br>quotient additive"]):::uptodate
    x544e14c8fac2c5b0(["metrics"]):::uptodate --> x3e9a828eb9618b81(["metrics_summary"]):::uptodate
    x8e3ad4805a2a7067>"summarizeWeight"]:::uptodate --> x3e9a828eb9618b81(["metrics_summary"]):::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> xe2f92c402667190b(["metrics_log_multiplicative<br>log multiplicative"]):::uptodate
    x2b659433eb98f15a(["list_metrics_log_multiplicative<br>log multiplicative"]):::uptodate --> xe2f92c402667190b(["metrics_log_multiplicative<br>log multiplicative"]):::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> x28aad13c773d162f["graph_quotient_additive<br>quotient additive"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> x28aad13c773d162f["graph_quotient_additive<br>quotient additive"]:::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> xabccbe5cf0b36246["raw_metrics_quotient_additive<br>quotient additive"]:::uptodate
    x28aad13c773d162f["graph_quotient_additive<br>quotient additive"]:::uptodate --> xabccbe5cf0b36246["raw_metrics_quotient_additive<br>quotient additive"]:::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> x57009f103fc37c59(["metrics_base_additive<br>base additive"]):::uptodate
    x252f864078c6d536(["list_metrics_base_additive<br>base additive"]):::uptodate --> x57009f103fc37c59(["metrics_base_additive<br>base additive"]):::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> xb7984997b0b65deb["raw_metrics_inv_log_additive<br>inv_log additive"]:::uptodate
    xa1dd96cdd2c764be["graph_inv_log_additive<br>inv_log additive"]:::uptodate --> xb7984997b0b65deb["raw_metrics_inv_log_additive<br>inv_log additive"]:::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> xd2502fa25b72dfe4(["metrics_quotient_additive<br>quotient additive"]):::uptodate
    xa48e1a19ce1dd4c8(["list_metrics_quotient_additive<br>quotient additive"]):::uptodate --> xd2502fa25b72dfe4(["metrics_quotient_additive<br>quotient additive"]):::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> x10f7d6996e0aef08["graph_product_additive<br>product additive"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> x10f7d6996e0aef08["graph_product_additive<br>product additive"]:::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> x9a70cdc22ac762b0(["list_metrics_resultant_additive<br>resultant additive"]):::uptodate
    x749fe0bb68397baa["raw_metrics_resultant_additive<br>resultant additive"]:::uptodate --> x9a70cdc22ac762b0(["list_metrics_resultant_additive<br>resultant additive"]):::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> xf790f113567ebe32(["list_metrics_inv_log_multiplicative<br>inv_log multiplicative"]):::uptodate
    xc5d78d328f7a6fee["raw_metrics_inv_log_multiplicative<br>inv_log multiplicative"]:::uptodate --> xf790f113567ebe32(["list_metrics_inv_log_multiplicative<br>inv_log multiplicative"]):::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> xf20669808bbd122d["graph_inv_log_multiplicative<br>inv_log multiplicative"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> xf20669808bbd122d["graph_inv_log_multiplicative<br>inv_log multiplicative"]:::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> xae2b4d2c9af9c3c7["raw_metrics_product_additive<br>product additive"]:::uptodate
    x10f7d6996e0aef08["graph_product_additive<br>product additive"]:::uptodate --> xae2b4d2c9af9c3c7["raw_metrics_product_additive<br>product additive"]:::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> x252f864078c6d536(["list_metrics_base_additive<br>base additive"]):::uptodate
    xddd1fc6bfe90d352["raw_metrics_base_additive<br>base additive"]:::uptodate --> x252f864078c6d536(["list_metrics_base_additive<br>base additive"]):::uptodate
    x3eac3c5af5491b67>"lsData"]:::uptodate --> xe58bddd751ff431b(["fpath"]):::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> x76500f7fa1fa59e7["graph_product_multiplicative<br>product multiplicative"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> x76500f7fa1fa59e7["graph_product_multiplicative<br>product multiplicative"]:::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> x31d7c7721d27b75d["raw_metrics_log_multiplicative<br>log multiplicative"]:::uptodate
    x7104dbe4edf98ce5["graph_log_multiplicative<br>log multiplicative"]:::uptodate --> x31d7c7721d27b75d["raw_metrics_log_multiplicative<br>log multiplicative"]:::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> xd82af0033b074547["raw_metrics_quotient_multiplicative<br>quotient multiplicative"]:::uptodate
    xdc98302eb141a058["graph_quotient_multiplicative<br>quotient multiplicative"]:::uptodate --> xd82af0033b074547["raw_metrics_quotient_multiplicative<br>quotient multiplicative"]:::uptodate
    xea537a2a683a578a>"bindMetrics"]:::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    x57009f103fc37c59(["metrics_base_additive<br>base additive"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    x4dbaa551a1b2b434(["metrics_base_multiplicative<br>base multiplicative"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    x7f51f65db61b1f99(["metrics_inv_log_additive<br>inv_log additive"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    xc2c3d6b2a64e37a5(["metrics_inv_log_multiplicative<br>inv_log multiplicative"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    x14f9d60ee7ff7a58(["metrics_log_additive<br>log additive"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    xe2f92c402667190b(["metrics_log_multiplicative<br>log multiplicative"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    x48f9b67f2af24b5b(["metrics_product_additive<br>product additive"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    x9710872a0428f5bb(["metrics_product_multiplicative<br>product multiplicative"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    xd2502fa25b72dfe4(["metrics_quotient_additive<br>quotient additive"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    xcfb2d306ba24a904(["metrics_quotient_multiplicative<br>quotient multiplicative"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    x536661abd4e99d87(["metrics_resultant_additive<br>resultant additive"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    x23c100bf125a9529(["metrics_resultant_multiplicative<br>resultant multiplicative"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> xa45c68f4eecac6bf["graph_resultant_additive<br>resultant additive"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> xa45c68f4eecac6bf["graph_resultant_additive<br>resultant additive"]:::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> xb07c0e7d07309a33(["list_metrics_base_multiplicative<br>base multiplicative"]):::uptodate
    x20b48fd38d63a83c["raw_metrics_base_multiplicative<br>base multiplicative"]:::uptodate --> xb07c0e7d07309a33(["list_metrics_base_multiplicative<br>base multiplicative"]):::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> x4dbaa551a1b2b434(["metrics_base_multiplicative<br>base multiplicative"]):::uptodate
    xb07c0e7d07309a33(["list_metrics_base_multiplicative<br>base multiplicative"]):::uptodate --> x4dbaa551a1b2b434(["metrics_base_multiplicative<br>base multiplicative"]):::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> x9710872a0428f5bb(["metrics_product_multiplicative<br>product multiplicative"]):::uptodate
    xbcf85a7029a82251(["list_metrics_product_multiplicative<br>product multiplicative"]):::uptodate --> x9710872a0428f5bb(["metrics_product_multiplicative<br>product multiplicative"]):::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> xc3afeb3a8b68e136["raw_metrics_log_additive<br>log additive"]:::uptodate
    x5ddc778ebd1511fe["graph_log_additive<br>log additive"]:::uptodate --> xc3afeb3a8b68e136["raw_metrics_log_additive<br>log additive"]:::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> x7104dbe4edf98ce5["graph_log_multiplicative<br>log multiplicative"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> x7104dbe4edf98ce5["graph_log_multiplicative<br>log multiplicative"]:::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> x5ddc778ebd1511fe["graph_log_additive<br>log additive"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> x5ddc778ebd1511fe["graph_log_additive<br>log additive"]:::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> x749fe0bb68397baa["raw_metrics_resultant_additive<br>resultant additive"]:::uptodate
    xa45c68f4eecac6bf["graph_resultant_additive<br>resultant additive"]:::uptodate --> x749fe0bb68397baa["raw_metrics_resultant_additive<br>resultant additive"]:::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> xfd6ca79b1f175a3f(["list_metrics_quotient_multiplicative<br>quotient multiplicative"]):::uptodate
    xd82af0033b074547["raw_metrics_quotient_multiplicative<br>quotient multiplicative"]:::uptodate --> xfd6ca79b1f175a3f(["list_metrics_quotient_multiplicative<br>quotient multiplicative"]):::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> x536661abd4e99d87(["metrics_resultant_additive<br>resultant additive"]):::uptodate
    x9a70cdc22ac762b0(["list_metrics_resultant_additive<br>resultant additive"]):::uptodate --> x536661abd4e99d87(["metrics_resultant_additive<br>resultant additive"]):::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> xddd1fc6bfe90d352["raw_metrics_base_additive<br>base additive"]:::uptodate
    x1496749256f55ed5["graph_base_additive<br>base additive"]:::uptodate --> xddd1fc6bfe90d352["raw_metrics_base_additive<br>base additive"]:::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> xa1dd96cdd2c764be["graph_inv_log_additive<br>inv_log additive"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> xa1dd96cdd2c764be["graph_inv_log_additive<br>inv_log additive"]:::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> x5967491eb9867b79(["list_metrics_log_additive<br>log additive"]):::uptodate
    xc3afeb3a8b68e136["raw_metrics_log_additive<br>log additive"]:::uptodate --> x5967491eb9867b79(["list_metrics_log_additive<br>log additive"]):::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> xc2c3d6b2a64e37a5(["metrics_inv_log_multiplicative<br>inv_log multiplicative"]):::uptodate
    xf790f113567ebe32(["list_metrics_inv_log_multiplicative<br>inv_log multiplicative"]):::uptodate --> xc2c3d6b2a64e37a5(["metrics_inv_log_multiplicative<br>inv_log multiplicative"]):::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> x57f78ac45da0a0a0["graph_base_multiplicative<br>base multiplicative"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> x57f78ac45da0a0a0["graph_base_multiplicative<br>base multiplicative"]:::uptodate
    x530f2fdf967c524c>"getMetrics"]:::uptodate --> x2dc8e27faf7c5664["raw_metrics_product_multiplicative<br>product multiplicative"]:::uptodate
    x76500f7fa1fa59e7["graph_product_multiplicative<br>product multiplicative"]:::uptodate --> x2dc8e27faf7c5664["raw_metrics_product_multiplicative<br>product multiplicative"]:::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> x02090f5acddb162e["graph_resultant_multiplicative<br>resultant multiplicative"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> x02090f5acddb162e["graph_resultant_multiplicative<br>resultant multiplicative"]:::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> x14f9d60ee7ff7a58(["metrics_log_additive<br>log additive"]):::uptodate
    x5967491eb9867b79(["list_metrics_log_additive<br>log additive"]):::uptodate --> x14f9d60ee7ff7a58(["metrics_log_additive<br>log additive"]):::uptodate
    xe58bddd751ff431b(["fpath"]):::uptodate --> x487cbf8b9ca9e729(["list_metrics_resultant_multiplicative<br>resultant multiplicative"]):::uptodate
    x47b488cb93e9530b["raw_metrics_resultant_multiplicative<br>resultant multiplicative"]:::uptodate --> x487cbf8b9ca9e729(["list_metrics_resultant_multiplicative<br>resultant multiplicative"]):::uptodate
    xc771947fa5a6f28e>"mkGraph"]:::uptodate --> xdc98302eb141a058["graph_quotient_multiplicative<br>quotient multiplicative"]:::uptodate
    xd5845efd825040d8["tbls"]:::uptodate --> xdc98302eb141a058["graph_quotient_multiplicative<br>quotient multiplicative"]:::uptodate
    x118c4b3508419f51>"combineMetrics"]:::uptodate --> x48f9b67f2af24b5b(["metrics_product_additive<br>product additive"]):::uptodate
    x4187040dac44a5dd(["list_metrics_product_additive<br>product additive"]):::uptodate --> x48f9b67f2af24b5b(["metrics_product_additive<br>product additive"]):::uptodate
    xc11069275cfeb620(["readme"]):::dispatched --> xc11069275cfeb620(["readme"]):::dispatched
    x07bf962581a33ad1{{"funs"}}:::uptodate --> x07bf962581a33ad1{{"funs"}}:::uptodate
    x2f12837377761a1b{{"pkgs"}}:::uptodate --> x2f12837377761a1b{{"pkgs"}}:::uptodate
    x026e3308cd8be8b9{{"pkgs_load"}}:::uptodate --> x026e3308cd8be8b9{{"pkgs_load"}}:::uptodate
    x4d3ec24f81457d7f{{"seed"}}:::uptodate --> x4d3ec24f81457d7f{{"seed"}}:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef dispatched stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 4 stroke-width:0px;
  linkStyle 135 stroke-width:0px;
  linkStyle 136 stroke-width:0px;
  linkStyle 137 stroke-width:0px;
  linkStyle 138 stroke-width:0px;
  linkStyle 139 stroke-width:0px;
```
