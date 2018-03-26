# dynprog: Domain-specific langauge for specifying dynamic programming algorithms.

Implements a small domain-specific language that translates recursions into
dynamic programming computations.

This is a resubmission with changes based on email. I have:

    - Added examples so "checking examples" should not show NONE.
        - %where% is the only exported function, so the examples are there
    - I have added a reference to Dynamic Programming on Wikipedia
      (it is a common algorithmic technique, so there is no obvious
      paper to quote; the paper introducing it is dated compared to
      modern algorithmic textbooks).

## Test environments
* local OS X install, R 3.4.4
* ubuntu 14.04 (on travis-ci), R 3.4.4
* win-builder (devel and release)
* RHub:
  
  - Fedora Linux, R-devel, clang, gfortran
  - Ubuntu Linux 16.04 LTS, R-release, GCC
  - Windows Server 2008 R2 SP1, R-devel, 32/64 bit
  
  On RHub on Windows a warning that Pandoc cannot
  find the badges images (which Pandoc always complain about on Windows).
  
  Other than that, the package checks.
  
## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
