using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GdfGithubWrapper
{
    public class GlobalGitData
    {
        private string author;
        private string repo;
        private string branch;
        private string rootDirPath;
        private string fixScheme = "https";
        private string fixHost = "github.com";

        private short fixMinSegments = 6;
        private short fixRepoSegmentIndex = 3;
        private short fixBranchSegmentIndex = 5;
        private short fixDirPathSegmentFirstIndex = 6;
        private short fixAuthorSegmentIndex = 2;

        private bool fixDirPathSegmentLastIndexIsLastIndex = true;

        private Nullable<short> fixDirPathSegmentLastIndex = null;

        public string Author
        {
            get
            {
                return author;
            }

            set
            {
                author = value;
            }
        }

        public string Repo
        {
            get
            {
                return repo;
            }

            set
            {
                repo = value;
            }
        }

        public string Branch
        {
            get
            {
                return branch;
            }

            set
            {
                branch = value;
            }
        }

        public string RootDirPath
        {
            get
            {
                return rootDirPath;
            }

            set
            {
                rootDirPath = value;
            }
        }

        public GlobalGitData(Uri GithubUrl, Singleton Singleton)
        {
            try
            {
                bool chk = validateGithubUrl(GithubUrl);
                if (chk)
                {
                    string[] segments = getGitSegmentsFromUrl(GithubUrl);
                    setPropertyFromSegments(segments);
                    Singleton.NewSingleton(this);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        // delegate for error throw
        delegate void thr(string url, string message);

        private bool validateGithubUrl(Uri githubUrl)
        {
            // lambda expression for error throw
            thr newThr = (u, m) =>
            {
                string e = u + m;
                Exception ex = new Exception(e);
                throw (ex);
            };


            //1) check url
            string url = githubUrl.ToString();
            bool chk = Uri.IsWellFormedUriString(url, UriKind.Absolute);

            if (chk == false)
            {
                newThr(url, " is not an absolute url");
            }

            //2) check host name
            string h = this.fixHost;
            string H = githubUrl.Host;

            if (h != H)
            {
                newThr(url, " is not a github url");
            }

            //3) check url scheme
            string s = this.fixScheme;
            string S = githubUrl.Scheme;

            if (s != S)
            {
                newThr(url, " is not a secure http url");
            }

            //4) check segments number
            int sn = this.fixMinSegments;
            int SN = githubUrl.Segments.Length;

            if (sn < SN)
            {
                newThr(url, " not contains all segments in url");
            }

            return true;
        }

        private string[] getGitSegmentsFromUrl(Uri githubUrl)
        {
            string[] arr = githubUrl.Segments;
            return arr;
        }

        private void setPropertyFromSegments(string[] segments)
        {
            //Reference:
            //	0: [String]Author
            //	1: [String]Repo
            //	2: [String]Branch
            //	3: [String]FirstDirPath

            //Retrieve global constants
            short ai = fixAuthorSegmentIndex;
            short ri = fixRepoSegmentIndex;
            short bi = fixBranchSegmentIndex;
            short dfi = fixDirPathSegmentFirstIndex;

            //DirPathSegmentLastIndex Pattern
            int? dli;
            if(fixDirPathSegmentLastIndexIsLastIndex)

            {
                dli = segments.Length;

            }
            else
            {
                dli = fixDirPathSegmentLastIndex;
            }
            
            author = segments[ai];
		    repo = segments[ri];
            branch = segments[bi];
            rootDirPath = string.Join("", segments, dfi, (dli - dfi));
        }
    }
}