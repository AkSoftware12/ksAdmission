import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/HexColorCode/HexColor.dart';
import '../Utils/image.dart';
import 'free_content_list.dart';

class FreeContentPage extends StatefulWidget {
  @override
  State<FreeContentPage> createState() => _FreeContentPageState();
}

class _FreeContentPageState extends State<FreeContentPage>
    with SingleTickerProviderStateMixin {

  bool isGrid = false;

  // ---------- Dummy Data (You can convert API later) ----------
  final List<Map<String, dynamic>> content = [
    {
      "title": "Free Demo Class",
      "sub": "12 Live Classes Available",
      "img": "https://i.ytimg.com/vi/T1LtnLfamQg/hqdefault.jpg"
    },
    {
      "title": "Premium Marketing Tips",
      "sub": "10 Modules Free",
      "img": "https://img.freepik.com/free-vector/tiny-students-with-huge-sign-pi-flat-vector-illustration-boy-girl-studying-math-algebra-school-college-holding-ruler-using-laptop-geometric-figures-background-education-concept_74855-23227.jpg?t=st=1766989689~exp=1766993289~hmac=dd9865519be7888ad9751c8bc8f7e1c5c4925d4524e433746ef45c1d426f1133&w=1480"
    },
    {
      "title": "Real Estate Beginner Guide",
      "sub": "6 Chapters Included",
      "img": "https://img.freepik.com/free-vector/colorful-flat-chemistry-background_23-2148160367.jpg?t=st=1766989820~exp=1766993420~hmac=bba1e25581deefa00f422a1df6ec74678c51c558745416680dd21b2d0a25eb7b&w=1480"
    },
    {
      "title": "Ads Setup Training",
      "sub": "Step by Step Tutorials",
      "img": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ------------------- Modern AppBar --------------------
      appBar: AppBar(
        backgroundColor: HexColor('#0e4ccc'),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        elevation: 3,
        title: Text("FREE CONTENT",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp,color: Colors.white),
        ),
        centerTitle: false,
        actions: [

          AnimatedScale(
            scale: 1,
            duration: Duration(milliseconds: 200),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => setState(() => isGrid = !isGrid),

              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blueAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: HexColor('#0e4ccc').withOpacity(.5),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ],
                  borderRadius: BorderRadius.circular(30),
                ),

                child: Row(
                  children: [
                    Icon(isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text(
                      isGrid ? "List View" : "Grid View",
                      style: TextStyle(color: Colors.white,fontSize: 13,fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),

          // Icon(Icons.share_outlined, color: Colors.white),
          // SizedBox(width: 12),
          // Icon(Icons.search, color: Colors.white),
          // SizedBox(width: 12),
        ],
      ),

      body: Stack(
        children: [
          Center(
            child: SizedBox(
              // height: 150.sp,
              width: double.infinity,
              child: Opacity(
                opacity: 0.1, // Adjust the opacity value (0.0 to 1.0)
                child: Image.asset(logo),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Card(
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // rounded (sp ki jagah px hota)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // ---------- Title & Toggle Premium Header ----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            // 🌈 Gradient Title
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (rect) => LinearGradient(
                                    colors: [HexColor('#0e4ccc'), Colors.blueAccent],
                                  ).createShader(rect),
                                  child: Text(
                                    "Explore Classes",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // required for shader mask
                                      letterSpacing: .8,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 18, color: HexColor('#0e4ccc')),
                                    SizedBox(width: 6),
                                    Text(
                                      "Learn free with high quality lessons!",
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(.65),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // 🔘 Premium Toggle Button
                          ],
                        ),

                      ],
                    ),
                  ),
                ),




                // ---------------- UI View Animated -----------------
                Expanded(
                  child: Padding(
                    padding:  EdgeInsets.all(5.sp),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder: (child,anim)=>
                          ScaleTransition(scale: anim,child: child),

                      child: isGrid
                          ? buildGridView()
                          : buildListView(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ List View Style -------------------
  Widget buildListView() {
    return ListView.separated(
      itemCount: content.length,
      separatorBuilder: (_,__) => SizedBox(height: 10),
      itemBuilder: (context,i){

        return GestureDetector(
          onTap: ()=> Navigator.push(context,
              MaterialPageRoute(builder: (_)=> FreeDemoClassPage())),

          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              // color: Colors.transparent,
              gradient: LinearGradient(
                colors: [Colors.white,HexColor('#eaf2ff')],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(
                  color: HexColor('#0e4ccc').withOpacity(.25),
                  blurRadius: 10,spreadRadius: 1,offset: Offset(0,6)
              )],
              // border: Border.all(color: Colors.grey.shade500,width: 1)
            ),
            child: Row(
              children: [
                Hero(
                  tag: content[i]["img"],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      content[i]["img"],
                      height: 75,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 75,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.image_not_supported_outlined,
                            size: 30, color: Colors.grey),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 75,
                          width: 100,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 14),

                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content[i]["title"],
                        style: TextStyle(fontSize: 13.sp,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: HexColor('#0e4ccc').withOpacity(.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        content[i]["sub"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: HexColor('#0e4ccc'),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),


                  ],
                )),

                Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: HexColor('#0e4ccc'),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_forward_ios,
                      size: 16,color: Colors.white),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------ Grid View Style -------------------
  Widget buildGridView() {
    return GridView.builder(
      itemCount: content.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: .93,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8),
      itemBuilder: (context,i){
        return InkWell(
          onTap: ()=> Navigator.push(context,
              MaterialPageRoute(builder: (_)=> FreeDemoClassPage())),

          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [BoxShadow(
                  color: HexColor('#0e4ccc').withOpacity(.25),
                  blurRadius: 8,offset: Offset(0,4)
              )],
            ),
            child: Column(
              children: [
                Hero(
                  tag: content[i]["img"],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      content[i]["img"],
                      height: 120.sp,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120.sp,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(Icons.broken_image_outlined,
                            size: 40, color: Colors.grey),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                    ),
                  ),
                ),



                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // -------- Title Row With Icon --------
                      Row(
                        children: [
                          Icon(Icons.play_circle_fill_rounded,   //<-- change icon anytime
                              size: 20, color: HexColor('#0e4ccc')),
                          SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              content[i]["title"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6),

                      // -------- Subtitle with tag style look --------
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: HexColor('#0e4ccc').withOpacity(.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          content[i]["sub"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor('#0e4ccc'),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
